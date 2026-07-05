# Vibrate lag/no-vibrate: root cause was device-tree only, no TWRP upstream change needed

**Repo:** `bootable/recovery` (TWRP-Test/android_bootable_recovery, `twrp-16.0`) — unmodified, byte-identical to upstream.
**Actual fix:** `device/nubia/PQ84P01/BoardConfig.mk`

## Root cause

`TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME` was set to the full dotted AIDL service name:

```makefile
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "android.hardware.vibrator.IVibrator/default"
```

`minuitwrp/events.cpp`'s FQNAME branch builds the instance name as:

```cpp
kVibratorInstance = std::string("android.hardware.vibrator.") + USE_QTI_AIDL_HAPTICS_FQNAME;
```

i.e. it expects `FQNAME` to be just the `<Interface>/<instance>` suffix, not the full name. With the
full name supplied, the prefix got applied twice, producing a bogus, never-registered service name:

```
android.hardware.vibrator.android.hardware.vibrator.IVibrator/default
```

`AServiceManager_getService()` was therefore doomed to fail on every call — this is what caused the
original severe per-tap touch lag (the failed lookup happening synchronously on the GUI/input thread),
and it's also why an initial async-caching patch to `events.cpp` still resulted in vibration silently
never working (the cached lookup just failed once and stayed null forever).

Confirmed via the device's VINTF manifest (`/vendor/etc/vintf/manifest/vendor.qti.hardware.vibrator.service.xml`):
the real registered name is `android.hardware.vibrator.IVibrator/default`, and via a reference device tree
(`YuKongA/twrp_device_xiaomi_sm8750_thales`) which sets `FQNAME` correctly as just `"IVibrator/vibratorfeature"`.

## Fix

```makefile
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/default"
```

One line, device tree only. No `bootable/recovery` change of any kind is required — `events.cpp` is
untouched, byte-identical to upstream `twrp-16.0`.

`libminuitwrp_defaults.go` (commit `83136d6f`, the only other local change in `bootable/recovery`)
is unrelated to this bug — it just translates `TW_SUPPORT_INPUT_AIDL_HAPTICS` into the
`-DUSE_QTI_AIDL_HAPTICS` cflag and must stay in place for the AIDL path to compile at all.
