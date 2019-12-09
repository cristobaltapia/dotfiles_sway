#!/usr/bin/env bash
# Very basic interface for pass using wofi

# Get all password files and create an array
root=~/.password-store

list_passwords() {
    shopt -s nullglob globstar
	cd "${root}" || exit
	pw_list=(**/*.gpg)
	printf '%s\n' "${pw_list[@]%.gpg}" | sort -n

}

SECRET=$(list_passwords | wofi -i --width 700 --height 250 --dmenu)

# Get password
PASSWD_PASS=$(pass ${SECRET})
# Strip extra lines
PASSWD_PASS=(${PASSWD_PASS[@]})

wl-copy -t -o ${PASSWD_PASS}
