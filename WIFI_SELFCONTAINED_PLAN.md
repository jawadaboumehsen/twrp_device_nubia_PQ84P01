# Plan: self-contained recovery WiFi (`wpa_supplicant_recovery`)

Status: **blocked at Phase 1** (see below). Not started beyond discovery.

## Goal

Make recovery WiFi independent of `/vendor` mounting, and drop the
`connect-wifi.sh` runtime patch by shipping our own `wpa_supplicant.conf`
instead of the vendor's.

## Current state (this tree)

`init.recovery.wifi.rc` runs the **vendor's own binary and config**:

```
service wpa_supplicant /vendor/bin/wpa_supplicant -Dnl80211 -iwlan0 -dd -O/tmp/recovery/sockets -c/vendor/etc/wifi/wpa_supplicant.conf
```

This only works if `/vendor` mounts successfully (erofs, AVB-verified, correct
slot). It also requires the `connect-wifi.sh` workaround (see `note.md` /
`CLAUDE.md`) because the vendor's default config prefers
`proto="WPA RSN WAPI"` and rejects normal APs outright.

## Reference architecture (`device/zte/sm88XX`, canoe/sm8850 platform)

That tree instead builds its own supplicant from AOSP source and bakes it into
the recovery ramdisk itself, with no `/vendor` dependency:

```makefile
TARGET_RECOVERY_DEVICE_MODULES += wpa_cli_recovery
TARGET_RECOVERY_DEVICE_MODULES += wpa_supplicant_recovery
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/wpa_cli_recovery
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/wpa_supplicant_recovery

BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WPA_SUPPLICANT_VERSION := VER_0_8_X
```

These `_recovery` build targets come from `external/wpa_supplicant_8`
(AOSP core source, not the vendor's prebuilt blob).

## Phases

1. **Feasibility discovery** (small) — confirm `external/wpa_supplicant_8` is
   checked out and buildable; confirm `BOARD_WLAN_DEVICE` value matches this
   device's actual driver stack.
2. **Build wiring** (small) — add the `TARGET_RECOVERY_DEVICE_MODULES` /
   `RECOVERY_BINARY_SOURCE_FILES` / `BOARD_WLAN_DEVICE` lines to
   `BoardConfig.mk`; write a TWRP-owned `wpa_supplicant.conf` defaulting to
   `proto=RSN`/`key_mgmt=WPA-PSK`.
3. **Runtime wiring** (small) — rewrite the `service wpa_supplicant` line in
   `init.recovery.wifi.rc` to launch the self-built binary + new config
   instead of the `/vendor/bin/...` path. Leave `connect-wifi.sh` in place
   but unused until Phase 4 passes.
4. **Build + on-device validation** (medium) — `mka recoveryimage`, flash to
   the connected test device, confirm `wpa_supplicant_recovery` starts
   without `/vendor` mounted and associates to a normal WPA2 AP with **no**
   `connect-wifi.sh` patch applied. Also test with `/vendor` deliberately
   unmounted to confirm the robustness win is real.
5. **Cleanup / rollback** (small) — if it works, remove the now-unnecessary
   `connect-wifi.sh` patch step. If it fails (e.g. vendor's `cnss2.ko` stack
   needs proprietary `nl80211` vendor commands the generic supplicant doesn't
   speak), revert `init.recovery.wifi.rc` and drop the `BoardConfig.mk`
   additions.

## Phase 1 result: BLOCKED

`external/wpa_supplicant_8` is **not checked out** in this tree.
`.repo/manifests/remove-minimal.xml` explicitly lists:

```xml
<remove-project path="external/wpa_supplicant_8" />
```

This build deliberately strips it out as part of its minimal-manifest
strategy (see `BoardConfig.mk`'s `ALLOW_MISSING_DEPENDENCIES`/`BUILD_BROKEN_*`
comments). So the `wpa_supplicant_recovery`/`wpa_cli_recovery` module targets
aren't buildable without first re-adding this entire external project via
`repo sync` — a materially bigger, more invasive action (unknown extra
dependencies, manifest drift from upstream TWRP's minimal-tree design) than
anything in Phases 2-3.

One thing Phase 1 did confirm: the Qualcomm WCN glue libraries for this
driver family are present —

```
hardware/qcom/wlan/wcn6740/qcwcn/wpa_supplicant_8_lib
hardware/qcom/wlan/legacy/qcwcn/wpa_supplicant_8_lib
```

— so `BOARD_WLAN_DEVICE := qcwcn` would be correct if this is ever revisited
(matches the WCN "peach" chipset this device also uses). It's specifically
the core `wpa_supplicant`/`wpa_cli` source that's missing, not the driver
glue.

## Decision

Nothing is currently broken — the vendor-binary + `connect-wifi.sh` setup
works. Re-adding `external/wpa_supplicant_8` reclassifies this from a config
change into a source-tree modification with its own risk, and should only be
done as a deliberate, separately-scoped decision, not folded into routine
`BoardConfig.mk` maintenance.

## Key risk if resumed

The vendor's `cnss2.ko`/WCN driver stack may expose proprietary `nl80211`
vendor commands the stock binary relies on that a generic AOSP-built
`wpa_supplicant_8` doesn't speak — this can only be confirmed empirically in
Phase 4 (on-device testing), not by reading source.
