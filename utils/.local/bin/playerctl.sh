#!/usr/bin/env bash

set -eou pipefail


ANS=$(echo -e "Next song\nPlay/Pause\nPrevious song\nStop\nOpen player" | wofi -dmenu -i -p "Music control")
case $ANS in
  "Next song") rmpc next;;
  "Play/Pause") rmpc togglepause;;
  "Previous song") rmpc prev;;
  "Stop") rmpc stop;;
  "Open player") rmpc;;
esac

