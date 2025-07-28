#!/usr/bin/env bash

# Get current song info from mpd
current=$(mpc current)

if [[ -n "$current" ]]; then
    echo "{\"text\": \"$current\", \"class\": \"playing\"}"
else
    echo "{\"text\": \"\", \"class\": \"stopped\"}"
fi
