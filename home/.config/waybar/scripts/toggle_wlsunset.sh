#!/usr/bin/env bash

wlstatus=$(systemctl --user is-active wlsunset.service)

if [[ $wlstatus == "active" ]]; then
    systemctl --user stop wlsunset.service
    pkill -SIGRTMIN+4 waybar
else
    systemctl --user start wlsunset.service
    pkill -SIGRTMIN+4 waybar
fi

