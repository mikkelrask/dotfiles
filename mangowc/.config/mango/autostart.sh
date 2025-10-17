#!/usr/bin/env bash

waybar -c /home/mr/.config/mango/waybar/config.jsonc >/dev/null &
mpd $HOME/.config/mpd/mpd.conf
trayscale --hide-window &
swaybg -i "/data/appdata/motoko/wallpapers/Mac OS/02. Mac OS.jpg"

