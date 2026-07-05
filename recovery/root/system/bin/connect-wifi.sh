#!/system/bin/sh
# Connects wlan0 to a WPA2-PSK network from TWRP recovery and brings up DHCP.
# Explicitly restricts proto/key_mgmt to exclude WAPI: this vendor wpa_supplicant
# build defaults new networks to proto="WPA RSN WAPI", and its BSS-matching logic
# then rejects any non-WAPI AP outright ("skip - non-WAPI network not allowed"),
# so a normal WPA2 AP never gets selected unless WAPI is excluded here.

CTRL=/tmp/recovery/sockets
IFACE=wlan0
WPA_CLI="wpa_cli -p $CTRL -i $IFACE"

SSID="$1"
PSK="$2"

if [ -z "$SSID" ] || [ -z "$PSK" ]; then
    echo "Usage: connect-wifi.sh <ssid> <password>"
    exit 1
fi

# Drop any previously configured networks so this is safe to re-run.
for id in $($WPA_CLI list_networks | awk 'NR>1 {print $1}'); do
    $WPA_CLI remove_network "$id" >/dev/null
done

NET_ID=$($WPA_CLI add_network)
$WPA_CLI set_network "$NET_ID" ssid "\"$SSID\"" >/dev/null
$WPA_CLI set_network "$NET_ID" psk "\"$PSK\"" >/dev/null
$WPA_CLI set_network "$NET_ID" proto RSN >/dev/null
$WPA_CLI set_network "$NET_ID" key_mgmt WPA-PSK >/dev/null
$WPA_CLI enable_network "$NET_ID" >/dev/null
$WPA_CLI select_network "$NET_ID" >/dev/null

echo "Waiting for association..."
i=0
STATE=""
while [ $i -lt 15 ]; do
    STATE=$($WPA_CLI status | grep wpa_state | cut -d= -f2)
    [ "$STATE" = "COMPLETED" ] && break
    sleep 1
    i=$((i + 1))
done

if [ "$STATE" != "COMPLETED" ]; then
    echo "Failed to associate (state: $STATE)"
    exit 1
fi
echo "Associated with $SSID."

start dhcpcd

echo "Waiting for DHCP lease..."
i=0
while [ $i -lt 15 ]; do
    IP=$(ifconfig $IFACE | grep 'inet addr:' | sed 's/.*inet addr:\([0-9.]*\).*/\1/')
    if [ -n "$IP" ]; then
        echo "Connected. IP: $IP"
        exit 0
    fi
    sleep 1
    i=$((i + 1))
done

echo "Associated but no DHCP lease obtained"
exit 1
