#!/bin/sh
# Force the OS version / security patch level keymint sees to values that are
# always higher than anything stored in the FBE key blobs on /metadata.
#
# Background: BoardConfig.mk originally pinned PLATFORM_VERSION/PLATFORM_SECURITY_PATCH
# to exactly match the blobs (Android 15, 2026-02-01), requiring this script to mount
# /system and /vendor, parse build.prop, and re-patch props on every boot so future
# OTAs wouldn't desync and retrigger keymint's KEY_REQUIRES_UPGRADE -> beginOperation()
# probe, which fails with INCOMPATIBLE_BLOCK_MODE (-8) on hardware-wrapped keys here.
#
# Verified experimentally (cold boot + recovery.log inspection) that keymint's check
# is a downgrade guard, not an exact match: current >= stored passes regardless of the
# actual stored value. So instead of tracking the live version, we just report values
# far in the future — always satisfies the guard, survives any OTA automatically, and
# no partition mounting/parsing is needed anymore. Same strategy used by the reference
# Xiaomi sm8750_thales tree.
#
# Also sets crypto.ready=1 which triggers TWRP's FBE decryption unlock sequence
# (defined in init.recovery.qcom_decrypt.fbe.rc).
#
# Runs from two places:
#   1. exec in on early-boot (init.recovery.qcom.rc) — may fail if DM not ready yet.
#   2. service started when ro.crypto.state=encrypted fires (qcom_decrypt.rc) — reliable path.

LOG=/tmp/prepdecrypt.log
log() { echo "prepdecrypt: $*" | tee -a "$LOG"; }

log "start (pid=$$)"

OS_VER="99.87.36"
SEC_PCH="2099-12-31"
log "forcing os=$OS_VER sec_patch=$SEC_PCH (always-future, downgrade-guard bypass)"

# Override in-memory properties (resetprop bypasses the read-only guard).
resetprop -n ro.build.version.release               "$OS_VER"
resetprop -n ro.system.build.version.release        "$OS_VER"
resetprop -n ro.build.version.security_patch        "$SEC_PCH"
resetprop -n ro.system.build.version.security_patch "$SEC_PCH"
resetprop -n ro.vendor.build.security_patch         "$SEC_PCH"
resetprop -n ro.vendor.build.version.release        "$OS_VER"

# Also patch prop.default so services that re-read properties from disk see the
# correct values (mirrors what the thales reference tree does).
DEFAULTPROP=/prop.default
if [ -f "$DEFAULTPROP" ]; then
    sed -i "s|^ro.build.version.release=.*|ro.build.version.release=$OS_VER|"          "$DEFAULTPROP"
    sed -i "s|^ro.build.version.security_patch=.*|ro.build.version.security_patch=$SEC_PCH|" "$DEFAULTPROP"
    sed -i "s|^ro.vendor.build.security_patch=.*|ro.vendor.build.security_patch=$SEC_PCH|" "$DEFAULTPROP"
    sed -i "s|^ro.vendor.build.version.release=.*|ro.vendor.build.version.release=$OS_VER|" "$DEFAULTPROP"
    log "prop.default patched"
fi

log "done — keymint will see os=$OS_VER sec_patch=$SEC_PCH"
setprop crypto.ready 1
log "crypto.ready=1 set"
exit 0
