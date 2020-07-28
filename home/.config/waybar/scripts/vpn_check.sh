#!/usr/bin/env bash
if [ -d "/proc/sys/net/ipv4/conf/tun0" ]; then
    echo '{"text":"Connected","class":"connected","percentage":100}'
elif [ -d "/proc/sys/net/ipv4/conf/ppp0" ]; then
    echo '{"text":"Connected","class":"connected","percentage":100}'
else
    echo '{"text":"Disconnected","class":"disconnected","percentage":0}'
fi
