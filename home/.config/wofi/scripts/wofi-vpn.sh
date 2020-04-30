#!/usr/bin/env bash
# Connect to VPN connections
# Modified from https://github.com/zbaylin/rofi-wifi-menu/blob/master/rofi-wifi-menu.sh

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=NAME,TYPE,STATE
POSITION=0
XOFF=-10
LOC=3
FONT="DejaVu Sans Mono 8"
CACHE=~/.local/tmp/vpn-wofi
WWIDTH=430

# if [ -r "$DIR/config" ]; then
#     source "$DIR/config"
# elif [ -r "$HOME/.config/wofi/wifi" ]; then
#     source "$HOME/.config/wofi/wifi"
# else
#     echo "WARNING: config file not found! Using default values."
# fi

LIST=$(nmcli --fields "$FIELDS" connection show | awk \
    -F "[  ]{2,}" \
    '$2 ~ /vpn/ { sub(/activated/, ""); printf "<tt>%s</tt>\n", $0 }')

#echo "${LIST_W}"
# For some reason rofi always approximates character width 2 short... hmmm
# WWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }')+2))
# Dynamically change the height of the rofi menu
LINENUM=$(echo "$LIST" | wc -l)

WHEIGHT=$((30*$LINENUM))

CHENTRY=$(echo -e "$LIST" | uniq -u | \
    wofi -i \
    --dmenu \
    -p "Choose a VPN connection: " \
    --width "$WWIDTH" \
    --height $WHEIGHT \
    --cache-file ${CACHE} \
    --location $LOC \
    --xoffset $XOFF | \
    sed -e 's/<[^>]*>//g')

rm ${CACHE}

ACTIVE=$(echo $CHENTRY | awk -F "[  ]{2,}" '{print //}')

VPNID=$(echo "$CHENTRY" | awk -F "[  ]{2,}" '{print $1}')

# It is assumed that if the connection is in active, then
# the user wants to deactivate it
if [[ $ACTIVE =~ 1 ]]; then
    nmcli connection down "$VPNID"
else
    nmcli connection up "$VPNID"
fi


