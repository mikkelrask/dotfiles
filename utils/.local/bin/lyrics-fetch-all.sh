#!/usr/bin/env bash

MUSICDIR="/home/mr/Music"
CURRENT_DIR="$(pwd)"

cd "$MUSICDIR" || exit 1

# Read directories into an array
mapfile -t artists < <(fd -t directory --max-depth=1 )

for ARTIST in "${artists[@]}"; do
  ARTIST="${ARTIST%/}"
  ARTISTPATH="$MUSICDIR/$ARTIST"
  cd "$ARTISTPATH" || exit 1

  mapfile -t albums < <(fd -t directory --max-depth=1)
  
  for ALBUM in "${albums[@]}"; do
    ALBUMPATH="$ARTISTPATH/$ALBUM"
    echo "Getting $ALBUM ($ALBUMPATH)"
    lyrics-fetch.sh "$ALBUMPATH" 
  done

  cd "$MUSICDIR" || exit 1
done

cd "$CURRENT_DIR" || exit 1
exit 0
