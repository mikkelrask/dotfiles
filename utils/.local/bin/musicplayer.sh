#!/usr/bin/env bash

set -eou pipefail

PLAYER="rmpc --address=/home/mr/.config/mpd/socket"

ghostty --title="rmpc" --config-file=/home/mr/.config/ghostty/borderless -e $PLAYER >/dev/null &2>1 & disown

