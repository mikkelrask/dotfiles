#!/usr/bin/env bash

# 🔧 Justér til din musikmappe
music_dir="/mnt/pool/Music"

# Læs JSON fra stdin
json=$(cat)

# Parse felter
title=$(echo "$json" | jq -r '.metadata.title // "Unknown Title"')
artist=$(echo "$json" | jq -r '.metadata.artist // "Unknown Artist"')
album=$(echo "$json" | jq -r '.metadata.album // "Unknown Album"')
release_date=$(echo "$json" | jq -r '.metadata.date // ""')

if [[ -z "$release_date" ]]; then
  year=""
else
  year="(${release_date:0:4})"
fi
relative_path=$(echo "$json" | jq -r '.file')
dir_path=$(dirname "$relative_path")
full_path="$music_dir/$relative_path"

# 🎨 Forsøg at finde cover i samme mappe
cover_path=""
for name in "cover.jpg" "folder.jpg" "front.jpg"; do
    candidate="$music_dir/$dir_path/$name"
    if [[ -f "$candidate" ]]; then
        cover_path="$candidate"
        break
    fi
done

# 📦 Hvis ingen coverfil fundet, prøv at udtrække embedded cover
if [[ -z "$cover_path" ]]; then
    tmp_cover="/tmp/current_cover.jpg"
    ffmpeg -loglevel error -y -i "$full_path" -an -vcodec copy "$tmp_cover" 2>/dev/null
    if [[ -s "$tmp_cover" ]]; then
        cover_path="$tmp_cover"
    fi
fi

# 💬 Send notifikation
if [[ -n "$cover_path" ]]; then
    notify-send "🎵 $artist - $title" "<i>$album</i> $year" -i "$cover_path" -t 5000
else
  notify-send "🎵 Playing: $title" "<b>$artist</b>\nAlbum: $album $year" -t 5000
fi

rm "$tmp_cover"
