#!/usr/bin/env bash

wlstatus=$(systemctl --user is-active wlsunset.service)

if [[ $wlstatus == "active" ]]; then
    systemctl --user stop wlsunset.service
else
    systemctl --user start wlsunset.service
fi

