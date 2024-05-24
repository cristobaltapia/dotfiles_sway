#!/usr/bin/env bash

nmcli --get-values ACTIVE,NAME,TYPE connection show \
  | awk -F ':' 'BEGIN {active = 0}
    /yes/ {
        if ($3 ~ /(wireguard|tun|vpn)/) {
            active = 1
            if ($2 ~ /Ho/) {
                home = 1
            }
            else {
                home = 0
            }
        }
    }
    END {
        if (active == 1) {
            if (home == 1) {
                print "{\"text\":\"Connected\",\"class\":\"connected\",\"percentage\":50}"
            } else {
                print "{\"text\":\"Connected\",\"class\":\"connected\",\"percentage\":100}"
        }
        } else {
            print "{\"text\":\"Disconnected\",\"class\":\"disconnected\",\"percentage\":0}"
        }
    }'
# pkill -SIGRTMIN+2 waybar
