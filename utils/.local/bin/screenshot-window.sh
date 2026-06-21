#!/usr/bin/env bash

REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
FILE="$HOME/Pictures/Screenshots/${REPO:-misc}-$(date +%s).png"
mkdir -p "$(dirname "$FILE")"

# Get focused window geometry via mmsg IPC
read X Y W H < <(
  mmsg get focusing-client | jq -r '[.x, .y, .width, .height] | @tsv'
)

# Sanity check (prevents silent failure)
if [[ -z "$X" || -z "$W" ]]; then
  notify-send "Screenshot failed" "Could not get window geometry"
  exit 1
fi
# Take screenshot
grim -g "${X},${Y} ${W}x${H}" "$FILE"

convert "$FILE" \
  \( +clone -background black -shadow 60x15+0+8 \) \
  +swap -background none -layers merge +repage \
  "$FILE"

# Copy to clipboard
wl-copy < "$FILE"

# Feedback
notify-send "Screenshot saved" "$FILE"
