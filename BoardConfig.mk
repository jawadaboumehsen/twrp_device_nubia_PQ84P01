#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Rules
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_NINJA_USES_ENV_VARS += RTIC_MPGEN
BUILD_BROKEN_PLUGIN_VALIDATION := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic

# Power
ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# Bootloader
PRODUCT_PLATFORM := sun
TARGET_BOOTLOADER_BOARD_NAME := sun
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

# Platform
TARGET_BOARD_PLATFORM := sun
TARGET_BOARD_PLATFORM_GPU := qcom-adreno830
QCOM_BOARD_PLATFORMS += sun

# Kernel
TARGET_KERNEL_ARCH            := arm64
TARGET_KERNEL_HEADER_ARCH     := arm64
BOARD_KERNEL_IMAGE_NAME       := Image
BOARD_BOOT_HEADER_VERSION     := 4
BOARD_KERNEL_PAGESIZE         := 4096
TARGET_KERNEL_CLANG_COMPILE   := true
TARGET_PREBUILT_KERNEL        := $(DEVICE_PATH)/prebuilt/kernel
BOARD_MKBOOTIMG_ARGS          += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS          += --pagesize $(BOARD_KERNEL_PAGESIZE)

# Ramdisk use lz4
BOARD_RAMDISK_USE_LZ4 := true

# A/B
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    vendor_boot \
    dtbo \
    vbmeta \
    vbmeta_system \
    odm \
    product \
    system \
    system_ext \
    system_dlkm \
    vendor \
    vendor_dlkm

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# Partitions — exact sizes from GPT (rawprogram4.xml, 4096-byte sectors)
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

# Workaround for error copying vendor files to recovery ramdisk
TARGET_COPY_OUT_VENDOR := vendor

TARGET_COPY_OUT_ODM := odm
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USES_VENDOR_DLKMIMAGE := true
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_RECOVERYIMAGE_PARTITION_SIZE  := 104857600   # 25600 sectors × 4096

# Dynamic Partition — super = 4194304 sectors × 4096 = 17179869184 (16 GiB)
BOARD_SUPER_PARTITION_SIZE := 17179869184
BOARD_SUPER_PARTITION_GROUPS := nubia_dynamic_partitions
BOARD_NUBIA_DYNAMIC_PARTITIONS_SIZE := 17175674880  # super - 4 MiB overhead
BOARD_NUBIA_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor vendor_dlkm odm


TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext


BOARD_BOOTIMAGE_PARTITION_SIZE      := 100663296   # 24576 sectors × 4096

BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296 # 24576 sectors × 4096
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE  := 8388608   # 2048  sectors × 4096
BOARD_DTBOIMG_PARTITION_SIZE          := 25165824   # 6144  sectors × 4096





# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

# Extras
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab

# Crypto
# Qualcomm keymint encodes os_version/patch level from ro.build.version.release and
# ro.build.version.security_patch, caches them at HAL startup, and checks them in
# begin_operation. A mismatch returns KEY_REQUIRES_UPGRADE (-62) -> upgrade_key(),
# which fails with INCOMPATIBLE_BLOCK_MODE (-8) on this device (hardware-wrapped
# inline-encryption keys don't support beginOperation, so the upgrade probe can't run).
#
# Originally worked around by matching these values exactly to what's stored in the
# FBE key blobs (Android 15, 2026-02-01), with prepdecrypt.sh re-detecting the live
# value from /system on every boot to track OTA changes. Verified experimentally
# (cold-boot test, recovery.log inspection) that keymint's check is actually a
# downgrade guard — current >= stored passes regardless of the exact value — so
# instead we report values always in the future. This survives any OTA automatically
# with no live re-detection needed. prepdecrypt.sh applies the matching runtime
# override via resetprop.
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_METADATA_PARTITION := true
TW_USE_FSCRYPT_POLICY := 2

# Tools
TW_INCLUDE_7ZA := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_ENABLE_ALL_PARTITION_TOOLS := true
TW_INCLUDE_NTFS_3G := true
TW_NO_EXFAT_FUSE := true
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_FUSE_NTFS := true
TARGET_USES_MKE2FS := true

# F2FS
TW_ENABLE_FS_COMPRESSION := false

# Debug
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TARGET_RECOVERY_DEVICE_MODULES += debuggerd libhardware
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
TARGET_RECOVERY_DEVICE_MODULES += strace
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace
RECOVERY_LIBRARY_SOURCE_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libhardware.so

# Fastbootd
TW_INCLUDE_FASTBOOTD := true

# Other TWRP Configurations

TW_THEME := landscape_hdpi
RECOVERY_TOUCHSCREEN_SWAP_XY := true
RECOVERY_TOUCHSCREEN_FLIP_Y := true
TW_FRAMERATE := 165
TW_MAX_PRINT_LOOPS := 20
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_NO_SCREEN_BLANK := true
TW_USE_DMCTL := true
TW_USE_TOOLBOX := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 4095
TW_DEFAULT_BRIGHTNESS := 1200
TW_EXTRA_LANGUAGES := true
TW_EXCLUDE_APEX := true
TW_HAS_EDL_MODE := true
TW_EXCLUDE_AUDIO := true
TW_SUPPORT_INPUT_AIDL_HAPTICS := true
# events.cpp builds the service name as "android.hardware.vibrator." + FQNAME, so this must be
# just "<Interface>/<instance>" (confirmed against the vibrator HAL's VINTF manifest) — the full
# dotted name here double-prefixes into a bogus name that AServiceManager_getService() never
# finds, silently breaking vibration. See UPSTREAM_VIBRATE_FIX.md.
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/default"
TW_SUPPORT_INPUT_AIDL_HAPTICS_FIX_OFF := true
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_BACKUP_EXCLUSIONS := /data/fonts
TW_DEVICE_VERSION := Nubia_PQ84P01-A15

# TWRP Touch — Synaptics TCM SPI (zte_tpd.ko)
TW_DIRECT_TOUCH_INPUT := "synaptics_tcm_touch"

# GKI vendor ramdisk module loading
# msm_drm.ko: Qualcomm SDE display driver — ensures DRM is available; without it TWRP
#   falls back to raw framebuffer with bootloader geometry (wrong rotation/size).
# zte_tpd.ko: Synaptics TCM SPI touch driver (alias spi:synaptics_tcm_spi in modules.alias).
#   Its only dep is panel_event_notifier.ko; modprobe auto-loads it via modules.dep.
# adsp_loader_dlkm.ko: loads ADSP firmware; required for audio and some HAL services.
# TW_LOAD_VENDOR_BOOT_MODULES enables the /lib/modules/ search path (vendor_boot ramdisk).
# init already loads all 304 vendor_boot modules (confirmed: msm_drm and zte_tpd both
# show "found module to dedupe" in recovery.log, meaning init pre-loaded them).
# EXCLUDE_GKI skips GKI-stock modules already in the kernel image (avoids conflicts).
# PREBUILT_MODULES_AT_FIRST ensures vendor modules are loaded before GKI-supplement modules.
TW_LOAD_VENDOR_MODULES := "adsp_loader_dlkm.ko rproc_qcom_common.ko qcom_q6v5.ko qcom_q6v5_pas.ko qcom_sysmon.ko zte_tpd.ko msm_drm.ko"
TW_LOAD_VENDOR_BOOT_MODULES := true
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
TW_LOAD_PREBUILT_MODULES_AT_FIRST := true
