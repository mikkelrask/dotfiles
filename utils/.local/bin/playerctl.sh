#!/usr/bin/env bash

set -eou pipefail

STATE_FILE="$HOME/.config/rmpc/selected_server"

if [[ -f "$STATE_FILE" ]]; then
  PLAYER_ARGS="--address=delos:6600"
else
  PLAYER_ARGS=""
fi
echo "PLAYER ARGS: $PLAYER_ARGS"

ANS=$(echo -e "Next song\nPlay/Pause\nPrevious song\nStop\nOpen player\nSelect server\nNow playing..." | wofi -H 150 --dmenu -M fuzzy -i -p "Music control" )
case $ANS in
  "Next song") rmpc $PLAYER_ARGS next;;
  "Play/Pause") rmpc $PLAYER_ARGS togglepause;;
  "Previous song") rmpc $PLAYER_ARGS prev;;
  "Stop") rmpc $PLAYER_ARGS stop;;
  "Open player") ghostty --config-file=/home/mr/.config/ghostty/borderless -e rmpc $PLAYER_ARGS;;
  "Select server") /home/mr/.local/bin/playerselector.sh;;
  "Now playing...") rmpc $PLAYER_ARGS song | player-notification.sh;;
esac

