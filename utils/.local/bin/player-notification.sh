#!/usr/bin/env bash
set -euo pipefail

music_dir="/mnt/pool/Music"
notification_id_file="/tmp/music_notification_id"

# Read JSON from stdin
json=$(cat)
title=$(echo "$json" | jq -r '.metadata.title // "Unknown Title"')
artist=$(echo "$json" | jq -r '.metadata.artist // "Unknown Artist"')
album=$(echo "$json" | jq -r '.metadata.album // "Unknown Album"')
release_date=$(echo "$json" | jq -r '.metadata.date // ""')

year=""
[[ -n "$release_date" ]] && year="(${release_date:0:4})"

relative_path=$(echo "$json" | jq -r '.file')
dir_path=$(dirname "$relative_path")
full_path="$music_dir/$relative_path"
base_name="$(basename "$relative_path" | sed 's/\.[^.]*$//')"

# Try to find a cover image
cover_path=""
for name in "cover.jpg" "folder.jpg" "front.jpg"; do
    candidate="$music_dir/$dir_path/$name"
    if [[ -f "$candidate" ]]; then
        cover_path="$candidate"
        break
    fi
done

# If not found, try to extract embedded cover
if [[ -z "$cover_path" ]]; then
    tmp_cover="/tmp/current_cover.jpg"
    ffmpeg -loglevel error -y -i "$full_path" -an -vcodec copy "$tmp_cover" 2>/dev/null
    if [[ -s "$tmp_cover" ]]; then
        cover_path="$tmp_cover"
    fi
fi

# Basic title/description
summary="♪ $artist - $title ♪"
body="$album $year"

# Optional: Read previous ID
prev_id=""
[[ -f "$notification_id_file" ]] && prev_id=$(<"$notification_id_file")

# Send notification
notify_args=(-t 5000 -u low)
[[ -n "$cover_path" ]] && notify_args+=(-i "$cover_path")
[[ -n "$prev_id" ]] && notify_args+=(-r "$prev_id")

# Run and save new ID if possible
if new_id=$(notify-send "${notify_args[@]}" -p "$summary" "$body" 2>/dev/null); then
    [[ "$new_id" =~ ^[0-9]+$ ]] && echo "$new_id" > "$notification_id_file"
fi
