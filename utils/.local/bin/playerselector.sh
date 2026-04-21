#!/usr/bin/env bash

set -eo pipefail

STATE_FILE="/home/mr/.config/rmpc/selected_server"

ANS=$(echo -e "Delos\nMotoko" | wofi -H 150 --dmenu -M fuzzy -i -p "Player selector: " )
case $ANS in
  "Delos") echo "delos" > "$STATE_FILE";;
  "Motoko") rm -f "$STATE_FILE";;
esac

if [[ $? == 0 ]]; then
  playerctl.sh
fi

