#!/bin/bash
kb=$(swaymsg -t get_inputs | jq -r \
    "first(.[]|select(.identifier == \"1:1:AT_Translated_Set_2_keyboard\" and .type == \"keyboard\")) \
    | .xkb_active_layout_name")

lay=$(echo $kb | awk '{print $1}')
var=$(echo $kb | awk '{s = "";
          for (i = 2; i <= NF; i++) s = s $i " ";
          print s}')

notify-send -a kb-layout "${lay}" "${var}"
