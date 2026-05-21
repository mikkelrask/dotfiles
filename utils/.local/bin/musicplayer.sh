#!/usr/bin/env bash

STATE_FILE="$HOME/.config/rmpc/selected_server"

if [[ -f "$STATE_FILE" ]]; then
  /usr/bin/ghostty --title="rmpc" --config-file=/home/mr/dotfiles/ghostty/.config/ghostty/borderless -e "/usr/bin/rmpc" "--address=delos:6600"
else
  /usr/bin/ghostty --title="rmpc" --config-file=/home/mr/dotfiles/ghostty/.config/ghostty/borderless -e "/usr/bin/rmpc" 
fi



