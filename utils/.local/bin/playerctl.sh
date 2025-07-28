#!/usr/bin/env bash

set -eou pipefail


ANS=$(echo -e "Next song\nPlay/Pause\nPrevious song\nStop\nOpen player\nNow playing..." | wofi -H 150 --dmenu -M fuzzy -i -p "Music control" )
case $ANS in
  "Next song") rmpc next;;
  "Play/Pause") rmpc togglepause;;
  "Previous song") rmpc prev;;
  "Stop") rmpc stop;;
  "Open player") ghostty --config-file=/home/mr/.config/ghostty/borderless -e rmpc;;
  "Now playing...") rmpc song | player-notification.sh;;
esac

