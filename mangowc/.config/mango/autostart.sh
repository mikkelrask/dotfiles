#!/usr/bin/env bash

waybar -c /home/mr/.config/waybar/mango.jsonc -s /home/mr/.config/waybar/mango.css >/dev/null 2>&1 &
swaybg -i "$(cat /home/mr/.local/share/setwall/wallpaper)" -m fill & disown
trayscale --hide-window &
swaync &
mpd /home/mr/.config/mpd/mpd.conf &
mpdscribble --conf /home/mr/.config/mpdscribble/mpdscribble.conf 
