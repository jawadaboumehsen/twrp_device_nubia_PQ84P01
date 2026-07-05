#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/nubia/PQ84P01

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
PRODUCT_DEVICE := PQ84P01
PRODUCT_NAME := twrp_PQ84P01
PRODUCT_BRAND := nubia
PRODUCT_MODEL := NP05J
PRODUCT_MANUFACTURER := nubia

PRODUCT_GMS_CLIENTID_BASE := android-nubia

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="sun-user 15 AQ3A.240812.002 REDMAGICOS10.5.9_NP05J_EU release-keys"

BUILD_FINGERPRINT := nubia/PQ84P01-EEA/PQ84P01:15/AQ3A.240812.002/REDMAGICOS10.5.9_NP05J_EU:user/release-keys

# Theme
TW_STATUS_ICONS_ALIGN := center
