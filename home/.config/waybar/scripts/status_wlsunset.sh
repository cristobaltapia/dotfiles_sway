#!/usr/bin/env sh

wlstatus=$(systemctl --user is-active wlsunset.service)

if [[ $wlstatus == "active" ]]; then
    echo '{"text": "", "alt": "", "tooltip": "wlsunset active", "class": "", "percentage": 100 }'
    pkill -SIGRTMIN+4 waybar
else
    echo '{"text": "", "alt": "", "tooltip": "wlsunset inactive", "class": "", "percentage": 0 }'
    pkill -SIGRTMIN+4 waybar
fi
