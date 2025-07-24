#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:"
  echo "  $0 -f input_video -m model_path"
  echo "  $0 -d input_directory -m model_path"
  exit 1
}

# Parse args
if [[ $# -lt 3 ]]; then usage; fi

MODE=""
INPUT=""
MODEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      MODE="file"
      INPUT="$2"
      shift 2
      ;;
    -d|--dir)
      MODE="dir"
      INPUT="$2"
      shift 2
      ;;
    -m|--model)
      MODEL="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$MODE" || -z "$INPUT" || -z "$MODEL" ]]; then
  usage
fi

if [[ ! -f "$MODEL" ]]; then
  echo "Error: Model file '$MODEL' not found."
  exit 1
fi

upscale_video() {
  local input_video="$1"
  local output_video="${input_video%.*}_upscaled.mkv"

  echo "Upscaling '$input_video' → '$output_video'"

  python /home/mr/Repos/Real-ESRGAN/inference_realesrgan_video.py \
    -i "$input_video" \
    -o "$output_video" \
    -n "$(basename "$MODEL" .pth)" \
    -s 2 \
    --tile 128 \
    --fp32
}

if [[ "$MODE" == "file" ]]; then
  if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file '$INPUT' not found."
    exit 1
  fi
  upscale_video "$INPUT"
elif [[ "$MODE" == "dir" ]]; then
  if [[ ! -d "$INPUT" ]]; then
    echo "Error: Input directory '$INPUT' not found."
    exit 1
  fi

  shopt -s nullglob
  files=("$INPUT"/*.{mp4,mkv,mov,avi})
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No video files found in directory '$INPUT'"
    exit 0
  fi

  for vid in "${files[@]}"; do
    upscale_video "$vid"
  done
else
  usage
fi

echo "All done!"

