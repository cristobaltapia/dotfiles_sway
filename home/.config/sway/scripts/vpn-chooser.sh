#!/usr/bin/env bash
# Connect to VPN connections

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=NAME,TYPE,STATE
WWIDTH=27

LIST=$(nmcli --fields "$FIELDS" connection show | awk \
    -F "[  ]{2,}" \
    '$2 ~ /vpn|wireguard/ {
      sub(/activated/, "󰕥");
      sub(/activating/, "");
      sub(/--/, "󰦜");
      printf "%-20s\t%s\n", $1,$3 }')

# Dynamically change the height of the rofi menu
LINENUM=$(echo "$LIST" | wc -l)

CHENTRY=$(echo -e "$LIST" | uniq -u | \
    fuzzel -d \
    --dmenu \
    -p "VPN: > " \
    --font 'FuraCode Nerd Font:size=13'\
    --border-color 'ebcb8bff' \
    -w $WWIDTH \
    -l $LINENUM \
    --anchor top-right | \
    sed -e 's/<[^>]*>//g')

rm ${CACHE}

ACTIVE=$(echo $CHENTRY | awk -F "[  ]{2,}" '{print /󰕥/}')

VPNID=$(echo "$CHENTRY" | awk -F "[  ]{2,}" '{print $1}')

# It is assumed that if the connection is in active, then
# the user wants to deactivate it
if [[ $ACTIVE =~ 1 ]]; then
    nmcli connection down "$VPNID"
else
    nmcli connection up "$VPNID"
fi

pkill -SIGRTMIN+2 waybar
