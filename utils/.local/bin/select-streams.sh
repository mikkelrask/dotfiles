#!/usr/bin/env bash
set -euo pipefail

input="$1"
streams=$(ffmpeg -i "$input" 2>&1 | grep -E 'Stream #[0-9]+:[0-9]+' || :)

selected=$(echo "$streams" | fzf --multi --preview 'echo {}' --height=20 --reverse)

if [[ -z "$selected" ]]; then
  echo "No streams selected."
  exit 1
fi

mapfile -t selected_indices < <(echo "$selected" | sed -n 's/.*Stream #\([0-9]\+:[0-9]\+\).*/\1/p')

read -rp "Enter output filename (e.g. output.mkv): " output

args=()
for idx in "${selected_indices[@]}"; do
  args+=("-map" "$idx")
done

ffmpeg -i "$input" "${args[@]}" -c copy "$output"
