#!/usr/bin/env bash

# Define input and output files
INPUT_FILE="$HOME/.config/stylix/palette.json"
OUTPUT_FILE="$HOME/.config/kitty/stylix.conf"

# Function to get color value safely
get_color() {
  local color=$(jq -r "$1" "$INPUT_FILE")
  # Check if the color is null or empty
  if [[ "$color" == "null" || -z "$color" ]]; then
    echo "Error: Color not found for $1"
    exit 1  # Exit if a color is not found
  else
    echo "$color"
  fi
}

# Read JSON and extract colors using jq
{
  echo "foreground               #$(get_color '.base05')"
  echo "background               #$(get_color '.base00')"
  echo "selection_foreground     #$(get_color '.base05')"
  echo "selection_background     #$(get_color '.base03')"

  echo "cursor                   #$(get_color '.base04')"
  echo "cursor_text_color        #$(get_color '.base05')"

  echo "url_color                #$(get_color '.base09')"

  echo "active_tab_foreground    #$(get_color '.base05')"
  echo "active_tab_background    #$(get_color '.base01')"
  echo "inactive_tab_foreground  #$(get_color '.base06')"
  echo "inactive_tab_background  #$(get_color '.base00')"

  echo "active_border_color      #$(get_color '.base0C')"
  echo "inactive_border_color    #$(get_color '.base02')"

  # Correctly referencing base0A to base0F
  for i in {0..9}; do
    color=$(get_color ".base0${i}")
    echo "color$i   #$color"
  done

  for i in {A..F}; do
    color=$(get_color ".base0$i")
    echo "color${i}   #$color"
  done
} > "$OUTPUT_FILE"

echo "Configuration updated in $OUTPUT_FILE"
