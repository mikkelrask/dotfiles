#!/usr/bin/env bash

set -eou pipefail

ENV_FILE="$HOME/.config/zsh/4-exports-and-source.zsh"
WALLPAPER_DIR="/data/appdata/motoko/wallpapers/"
START_DIR=$(pwd)

GET_THE_PAPERS() {
  cd $WALLPAPER_DIR
  png=$(fd -e=png .)
  jpg=$(fd -e=jpg .)
  gif=$(fd -e=gif .)
  WALLPAPERS="$png $jpg $gif"
  WALLPAPER=$(echo "$WALLPAPERS" | fzf )
  echo "$WALLPAPER"
  SET_WALLPAPER "$WALLPAPER"
}


SET_WALLPAPER() {
  NEW_WALL="$WALLPAPER_DIR$1"
  hellwal -i "$NEW_WALL" -o "/home/mr/.config/hellwal/o" >/dev/null 
  echo "$NEW_WALL" > "/home/mr/.local/share/setwall/wallpaper"
  killall -q swaybg
  swaybg -i "$NEW_WALL" -m fill >/dev/null &2>1 & disown 
  killall -q waybar
  sleep 1
  waybar -c "/home/mr/.config/waybar/mango.jsonc" -s "/home/mr/.config/waybar/mango.css" >/dev/null &2>1 & disown 
}

CHECK_CURRENT() {
  if [ "$WALLPAPER" = '' ]; then
    WALLPAPER=$(GET_THE_PAPERS)
  else
    echo "set"
  fi
  echo "Wallpaper set to: $WALLPAPER"
}

#SET_ENV_FILE() {
#  echo "passed: $1"
#  sed "s/$WALLPAPER=*/$1/g" "$ENV_FILE" 
#}

CHECK_CURRENT
cd "$START_DIR"
