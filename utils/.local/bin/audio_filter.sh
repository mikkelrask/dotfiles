#!/usr/bin/env bash
set -euo pipefail

# Input handling
file="$1"
output="${file%.*}.hq.${file##*.}"

# EQ file handling
if [[ "${2-}" == "--eq" || "${2-}" == "-e" ]]; then
  eqfile="${3-}"
  [[ -f "$eqfile" ]] || { echo "❌ EQ file not found: $eqfile"; exit 1; }
  use_eq=1
else
  use_eq=0
fi

# Select only key frequency bands (reducing from ~180 to ~10)
get_key_bands() {
  local eqfile="$1"
  declare -A bands=(
    [60]="v3"    # Bass
    [250]="v7"   # Low mids
    [1000]="v20" # Presence
    [3000]="v40" # High mids
    [6000]="v60" # Brilliance
    [12000]="v90" # Air
  )
  
  local filter=""
  for freq in "${!bands[@]}"; do
    gain=$(grep -o "${bands[$freq]}=\"[^\"]*\"" "$eqfile" | awk -F= '{print $2}' | tr -d '"')
    [[ -z "$gain" ]] && gain=0
    
    # Clamp gain to safe levels and round
    gain=$(awk -v g="$gain" 'BEGIN {g=g>6?6:(g<-6?-6:g); printf "%.1f", g}')
    
    [[ -n "$filter" ]] && filter+=","
    filter+="equalizer=f=${freq}:width_type=h:width=1:g=${gain}"
  done
  echo "$filter"
}

# Process in stages to prevent clipping
process_audio() {
  if (( use_eq )); then
    echo "🔧 Applying simplified EQ..."
    key_eq=$(get_key_bands "$eqfile")
    echo "⚙️ Using EQ: $key_eq"
    
    # Stage 1: Apply EQ with -6dB headroom
    ffmpeg -hide_banner -loglevel error -y -i "$file" \
      -af "volume=-6dB,${key_eq}" \
      -c:a pcm_s24le "${file%.*}_stage1.wav"
    
    # Stage 2: Loudness normalization
    ffmpeg -hide_banner -loglevel error -y -i "${file%.*}_stage1.wav" \
      -af loudnorm=i=-19:tp=-2:lra=11:linear=true \
      -c:a aac -b:a 192k "$output"
    
    # Cleanup
    rm "${file%.*}_stage1.wav"
  else
    # Just normalize if no EQ
    ffmpeg -hide_banner -loglevel error -y -i "$file" \
      -af loudnorm=i=-19:tp=-2:lra=11:linear=true \
      -c:a aac -b:a 192k "$output"
  fi
}

# Run processing
process_audio
echo "✅ Done: $output"
