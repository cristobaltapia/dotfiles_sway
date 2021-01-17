#!/usr/bin/env bash
# Very basic interface for pass using wofi

# Get all password files and create an array
root=~/.password-store
CACHE=~/.local/tmp/pass_wofi
seat=seat0

list_passwords() {
    shopt -s nullglob globstar
	cd "${root}" || exit
	pw_list=(**/*.gpg)
	printf '%s\n' "${pw_list[@]%.gpg}" | sort -n

}

prompt='search for passwords...'
SECRET=$(list_passwords | wofi -i --width 700 --lines 20 --height 250 --prompt="${prompt}" --dmenu --cache-file ${CACHE})

# Ask whether pass, user or both are required

options=("Password" \
        "User" \
        "User and password" \
        "QR-Code")

option=$(printf '%s\n' "${options[@]%}" | wofi -i --dmenu --width 400 --lines 4 --prompt="..." --cache-file /dev/null)

echo $option

case ${option} in
  Password )
    echo "Test"
    ydotool type $(pass get_pass ${SECRET})
    ;;
  User )
    ydotool type $(pass get_user ${SECRET})
    ;;
  "User and password" )
    ydotool type $(pass get_user ${SECRET})
    ydotool key  TAB
    ydotool type $(pass get_pass ${SECRET})
    ;;
  "QR-Code" )
    if [[ $SECRET =~ wifi$ ]]; then
      # Produce a valid wifi QR-code
      WIFISSID=$(pass get_user ${SECRET})
      WIFIPASS=$(pass get_pass ${SECRET})
      WIFIQR="WIFI:T:WPA;S:${WIFISSID};P:${WIFIPASS};;"
      qrencode -s 8 -o - $WIFIQR | feh --title "pass: QR-WIFI" -
    else
      # Only password
      pass show -q1 ${SECRET}
    fi
    ;;
esac

# wl-copy -o -s ${seat} ${PASSWD_PASS}
