#!/usr/bin/env bash
# Connect to WIFI
# Modified from https://github.com/zbaylin/rofi-wifi-menu/blob/master/rofi-wifi-menu.sh

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=SSID,SECURITY,BARS
POSITION=0
XOFF=-10
LOC=3
CACHE=~/.local/tmp/wifi-wofi
WWIDTH=410
MAXHEIGHT=1000

# if [ -r "$DIR/config" ]; then
#     source "$DIR/config"
# elif [ -r "$HOME/.config/wofi/wifi" ]; then
#     source "$HOME/.config/wofi/wifi"
# else
#     echo "WARNING: config file not found! Using default values."
# fi

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | awk '{ printf "<tt>%s</tt>\n", $0 }')

# Bluetooth connections
LISTB=$(nmcli --fields NAME,TYPE con show | awk '/bluetooth/ { printf "<tt>%s</tt>\n", $0 }')
#echo "${LIST_W}"
# For some reason rofi always approximates character width 2 short... hmmm
# WWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }')+2))
# Dynamically change the height of the rofi menu

WHEIGHT=$((30*$LINENUM))

if (($WHEIGHT > $MAXHEIGHT)) ; then
    echo $WHEIGHT
    WHEIGHT=${MAXHEIGHT}
fi

# Gives a list of known connections so we can parse it later
KNOWNCON=$(nmcli connection show | awk -F '[[:space:]][[:space:]]+' '{printf "%s\n", $1}')
# Really janky way of telling if there is currently a connection
CONSTATE=$(nmcli -fields WIFI g | awk '/enabled|disabled/ { print $0}')

CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

if [[ ! -z $CURRSSID ]]; then
	HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc )
fi

LINENUM=$(echo -e "toggle\nmanual\n${LIST}\n${LISTB}" | wc -l)

# If there are more than 20 SSIDs, the menu will still only have 20 lines
if [ "$LINENUM" -gt 20 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
	LINENUM=20
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	LINENUM=1
fi


if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="toggle on"
fi
echo $TOGGLE


CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST\n$LISTB" | uniq -u | \
    wofi -i --dmenu -p "Wi-Fi SSID: " --width "$WWIDTH" --lines ${LINENUM} --cache-file /dev/null --location $LOC --xoffset $XOFF | awk -F "[  ]{2,}" '{gsub(/<[^>]*>/, ""); print $0}')

rm ${CACHE}

SECURITY=$(echo "$CHENTRY" | awk -F "[  ]{2,}" '{print $2}')

CHSSID=$(echo "$CHENTRY" | awk -F "[  ]{2,}" '{print $1}')

# If the user inputs "manual" as their SSID in the start window, it will bring them to this screen
if [ "$CHENTRY" = "manual" ] ; then
	# Manual entry of the SSID and password (if appplicable)
	MSSID=$(echo "enter the SSID of the network (SSID,password)" | wofi --dmenu -p "Manual Entry: " --cache-file ${CACHE})
	# Separating the password from the entered string
	MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')

	#echo "$MSSID"
	#echo "$MPASS"

	# If the user entered a manual password, then use the password nmcli command
	if [ "$MPASS" = "" ]; then
		nmcli dev wifi con "$MSSID"
	else
		nmcli dev wifi con "$MSSID" password "$MPASS"
	fi

elif [ "$CHENTRY" = "toggle on" ]; then
	nmcli radio wifi on

elif [ "$CHENTRY" = "toggle off" ]; then
	nmcli radio wifi off

else

	# If the connection is already in use, then this will still be able to get the SSID
	if [ "$CHSSID" = "*" ]; then
		CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
	fi

	# Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process

	if [[ $(echo "$KNOWNCON" | grep -w "$CHSSID") = "$CHSSID" ]]; then
		nmcli con up "$CHSSID"
	else
		nmcli dev wifi con "$CHSSID"
	fi

fi