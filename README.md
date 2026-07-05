# Device tree for nubia NP05J (PQ84P01)

TWRP recovery device tree for the ZTE nubia NP05J / RedMagic (PQ84P01), Qualcomm SM8750 platform, Android 15.

## Features

- [x] ADB
- [x] Decryption
- [x] Display
- [x] Fastbootd
- [x] Flashing
- [x] MTP
- [x] Sideload
- [x] USB-OTG
- [x] Vibrator
- [x] WLAN

## Build

```
source build/envsetup.sh
lunch twrp_PQ84P01-bp2a-eng
make -j$(nproc) recoveryimage
```

## Documentation

- [`note.md`](note.md) — using WiFi and ADB-over-WiFi in recovery
- [`UPSTREAM_Edite.md`](UPSTREAM_Edite.md) — changes made to upstream `bootable/recovery`

---

```
#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
```
