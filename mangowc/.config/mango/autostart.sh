#!/usr/bin/env bash

trayscale --hide-window &
swaync &
mpd /home/mr/.config/mpd/mpd.conf &
sleep 2
swaybg -i $(cat /home/mr/.local/share/setwall/wallpaper) -m fill & disown
waybar -c /home/mr/.config/waybar/mango.jsonc -s /home/mr/.config/waybar/mango.css >/dev/null &2>1 
