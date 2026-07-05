# Using WiFi in TWRP recovery (Nubia PQ84P01)

TWRP itself has no WiFi settings screen — everything below is done through
`adb shell`. Once connected, WiFi can be used for network backups/restores,
reaching an OTA/update server, or ADB over WiFi (see below).

## Connect to a WiFi network

```
adb wait-for-device
adb shell sh /system/bin/connect-wifi.sh "<SSID>" "<password>"
```

Example:

```
adb shell sh /system/bin/connect-wifi.sh "Jawad" "12341234"
```

This script (`recovery/root/system/bin/connect-wifi.sh` in this device tree):
1. Clears any previously configured networks (safe to re-run).
2. Registers the network via `wpa_cli`, explicitly setting `proto=RSN` and
   `key_mgmt=WPA-PSK`. This is required: this vendor's `wpa_supplicant`
   defaults new networks to `proto="WPA RSN WAPI"`, and its BSS-matching logic
   then rejects any *non*-WAPI AP outright (`skip - non-WAPI network not
   allowed`). Without forcing `proto=RSN`, a normal WPA2 AP will never
   associate — supplicant just sits in `wpa_state=SCANNING` forever.
3. Waits (up to 15s) for `wpa_state=COMPLETED`.
4. Starts `dhcpcd` and waits (up to 15s) for an IPv4 lease.
5. Prints the assigned IP on success.

To check status manually at any point:

```
adb shell "wpa_cli -p /tmp/recovery/sockets -i wlan0 status"
adb shell "ifconfig wlan0"
```

## Connect ADB over WiFi

Once `connect-wifi.sh` has reported an IP, switch adbd to TCP mode over the
existing USB connection, then connect over WiFi:

```
adb tcpip 5555
adb connect <ip-from-connect-wifi.sh>:5555
```

`adb devices -l` should then show the device twice (once over `usb:`, once
over the WiFi IP). You can unplug the USB cable at this point and keep using
adb over WiFi — useful for GUI-only interaction where you don't want a cable
in the way (e.g. testing backup/restore from a network share).

To go back to USB-only:

```
adb -s <ip>:5555 usb
```

Note: ADB-over-WiFi state (the TCP listener) does not survive a reboot of
the recovery — after any reboot you'll need to `adb tcpip 5555` again over
USB before `adb connect` will work again.
