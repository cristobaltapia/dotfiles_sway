#!/bin/sh
# Taken from https://github.com/luispabon/sway-dotfiles/blob/master/scripts/wofi-power.sh

# if rofi >= 1.5.2 "Lock \x00icon\x1ffile-browser," works

entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

# selected=$(echo $entries | rofi -show-icons -m 0 -dmenu -sep ',' -p "power" -i | awk '{print tolower($1)}')
selected=$(printf $entries|wofi --width 300 --height 150 --dmenu --cache-file /dev/null | awk '{print tolower($1)}')

case $selected in
  logout)
    swaymsg exit;;
  lock)
    exec swaylock-blur --blur-sigma 40 -- -f;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
