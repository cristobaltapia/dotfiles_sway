#!/usr/bin/env bash
# Very basic interface for pass using wofi

# Get all password files and create an array
root=~/.password-store
CACHE=~/.local/tmp/pass_wofi

list_passwords() {
    shopt -s nullglob globstar
	cd "${root}" || exit
	pw_list=(**/*.gpg)
	printf '%s\n' "${pw_list[@]%.gpg}" | sort -n

}

prompt='search for passwords...'
SECRET=$(list_passwords | wofi -i --width 700 --height 250 --prompt="${prompt}" --dmenu --cache-file ${CACHE})

# Get password
PASSWD_PASS=$(pass ${SECRET})
# Strip extra lines
PASSWD_PASS=(${PASSWD_PASS[@]})

wl-copy -o ${PASSWD_PASS}
