# Vibrate lag/no-vibrate: root cause was device-tree only

**Repo:** `bootable/recovery` (TWRP-Test/android_bootable_recovery, `twrp-16.0`) — the only local commit is
`83136d6f` (`libminuitwrp_defaults.go`, adds the `-DUSE_QTI_AIDL_HAPTICS` cflag so the AIDL vibrator path
compiles at all), unrelated to this bug.
**Actual fix:** `device/nubia/PQ84P01/BoardConfig.mk`

## Root cause

`TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME` was set to the full dotted AIDL service name:

```makefile
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "android.hardware.vibrator.IVibrator/default"
```

TWRP expects `FQNAME` to be just the `<Interface>/<instance>` suffix and prepends the
`android.hardware.vibrator.` prefix itself. With the full name supplied, the prefix got applied
twice, producing a bogus, never-registered service name:

```
android.hardware.vibrator.android.hardware.vibrator.IVibrator/default
```

Looking up that name was therefore doomed to fail on every call — this is what caused the original
severe per-tap touch lag (the failed lookup happening synchronously on the GUI/input thread), and
it's also why vibration silently never worked (the lookup just failed once and stayed null forever).

Confirmed via the device's VINTF manifest (`/vendor/etc/vintf/manifest/vendor.qti.hardware.vibrator.service.xml`):
the real registered name is `android.hardware.vibrator.IVibrator/default`, and via a reference device tree
(`YuKongA/twrp_device_xiaomi_sm8750_thales`) which sets `FQNAME` correctly as just `"IVibrator/vibratorfeature"`.

## Fix

```makefile
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/default"
```

One line, device tree only.
