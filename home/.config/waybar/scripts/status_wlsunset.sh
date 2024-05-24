#!/usr/bin/env sh

wlstatus=$(systemctl --user is-active wlsunset.service)

if [[ $wlstatus == "active" ]]; then
    echo '{"text": "", "alt": "", "tooltip": "wlsunset active", "class": "active", "percentage": 100 }'
else
    echo '{"text": "", "alt": "", "tooltip": "wlsunset inactive", "class": "inactive", "percentage": 0 }'
fi
