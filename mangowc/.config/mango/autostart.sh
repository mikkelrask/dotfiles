#!/usr/bin/env bash

trayscale --hide-window &
waybar -c /home/mr/.config/waybar/config -s /home/mr/.config/waybar/style.css >/dev/null 2>&1 & disown
swaybg -i /home/mr/Pictures/4k-Red-Sun-Illuminating-Japanese-Temple-Mountain-Scene.jpg -m fill & disown
swaync &
mpd --no-daemon /home/mr/.config/mpd/mpd.conf &
mpdscribble -D --conf /home/mr/.config/mpdscribble/mpdscribble.conf &
swayidle -w timeout 1200 \
    'swaylock  -f \
        --screenshots --clock\
          --timestr="%H:%M" \
          --effect-blur 10x5 \
        --indicator \
        -indicator-idle-visible \
        --indicator-radius 100 \
        --fade-in 0.4 \
        --indicator-thickness 7 \
        --indicator-caps-lock \
        --ring-color 00000000 \
        --key-hl-color 34bdebff \
        --bs-hl-color ed8796ff \
        --inside-color 00000000 \
        --inside-clear-color 00000000 \
        --inside-ver-color 00000000 \
        --inside-wrong-color 00000000 \
        --ring-clear-color 00000000 \
        --ring-wrong-color 00000000 \
        --ring-ver-color 00000000 \
        --line-color 00000000 \
        --text-color 8a8a8aff \
        --text-clear-color f2d5cfff \
        --text-ver-color 8a8a8aff \
        --text-wrong-color ed8796ff \
        --effect-vignette 0.5:0.5'
