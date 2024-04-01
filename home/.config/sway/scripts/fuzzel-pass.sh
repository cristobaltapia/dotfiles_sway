#!/usr/bin/env bash
# Very basic interface for pass using wofi

# Get all password files and create an array
root=~/.password-store
seat=seat0

fuzzel_opt="--border-color=bf616aff"

list_passwords() {
    shopt -s nullglob globstar
	cd "${root}" || exit
	pw_list=(**/*.gpg)
	printf '  %s\n' "${pw_list[@]%.gpg}" | sort -n

}

prompt='pass > '
SECRET=$(list_passwords | fuzzel ${fuzzel_opt} -d --width=25 --lines=10 --prompt="${prompt}" | \
  awk '{print $2}')

[[ -z "$SECRET" ]] && { echo "No secret chosen. Exiting..." ; exit 1; }

# Ask whether pass, user or both are required
options=("Password" \
        "User and password" \
        "User" \
        "QR-Code")

option=$(printf '%s\n' "${options[@]%}" | fuzzel ${fuzzel_opt} --dmenu --width 20 --lines 4 --prompt="> ")

case ${option} in
  Password )
    # wlrctl keyboard type $(pass get_pass ${SECRET})
    pass get_pass ${SECRET} | wl-copy
    ;;
  User )
    wlrctl keyboard type $(pass get_user ${SECRET})
    ;;
  "User and password" )
    wlrctl keyboard type $(pass get_user ${SECRET})
    ydotool key 15:1 15:0
    # wlrctl keyboard type $(pass get_pass ${SECRET})
    pass get_pass ${SECRET} | wl-copy
    ;;
  "QR-Code" )
    if [[ $SECRET =~ wifi$ ]]; then
      # Produce a valid wifi QR-code
      WIFISSID=$(pass get_user ${SECRET})
      WIFIPASS=$(pass get_pass ${SECRET})
      WIFIQR="WIFI:T:WPA;S:${WIFISSID};P:${WIFIPASS};;"
      qrencode -s 8 -o - $WIFIQR | feh --title "pass: QR-WIFI" --info "echo 'WiFi: ${WIFISSID}'" -
    else
      # Only password
      pass show -q1 ${SECRET}
    fi
    ;;
esac

# wl-copy -o -s ${seat} ${PASSWD_PASS}

