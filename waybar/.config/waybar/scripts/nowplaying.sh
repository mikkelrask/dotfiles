#!/usr/bin/env bash

# Check if anything is playing
status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" ]]; then
    artist=$(playerctl metadata artist)
    title=$(playerctl metadata title)
    echo "{\"text\": \"$artist - $title\", \"class\": \"playing\"}"
elif [[ "$status" == "Paused" ]]; then
    artist=$(playerctl metadata artist)
    title=$(playerctl metadata title)
    echo "{\"text\": \"⏸ $artist - $title\", \"class\": \"paused\"}"
else
    echo "{\"text\": \"\", \"class\": \"stopped\"}"
fi
