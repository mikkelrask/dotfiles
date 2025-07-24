#!/bin/bash

# Script to mux subtitles with video files
# Looks for .en.srt (English) and .da.srt (Danish) files and adds them to video files

for video in *.mkv *.mp4; do
    # Skip if no video files found (glob didn't match)
    [[ ! -f "$video" ]] && continue
    
    # Get the base name without extension
    base="${video%.*}"
    
    # Check for subtitle files
    en_sub="${base}.en.srt"
    da_sub="${base}.da.srt"
    
    # Skip if no subtitle files exist
    [[ ! -f "$en_sub" && ! -f "$da_sub" ]] && continue
    
    echo "Processing: $video"
    
    # Build ffmpeg command
    cmd="ffmpeg -i \"$video\""
    
    # Add subtitle inputs and track input indices
    input_index=1
    en_input=""
    da_input=""
    
    if [[ -f "$en_sub" ]]; then
        cmd+=" -i \"$en_sub\""
        en_input=$input_index
        ((input_index++))
    fi
    if [[ -f "$da_sub" ]]; then
        cmd+=" -i \"$da_sub\""
        da_input=$input_index
        ((input_index++))
    fi
    
    # Copy video/audio streams
    cmd+=" -c copy"
    
    # Map all streams explicitly
    cmd+=" -map 0:v -map 0:a"
    
    # Map subtitle streams and set codec
    sub_output_index=0
    if [[ -n "$en_input" ]]; then
        cmd+=" -map $en_input:0"
        if [[ "$video" == *.mkv ]]; then
            cmd+=" -c:s:$sub_output_index srt"
        else
            cmd+=" -c:s:$sub_output_index mov_text"
        fi
        cmd+=" -metadata:s:s:$sub_output_index language=eng -metadata:s:s:$sub_output_index title=\"English\""
        ((sub_output_index++))
    fi
    if [[ -n "$da_input" ]]; then
        cmd+=" -map $da_input:0"
        if [[ "$video" == *.mkv ]]; then
            cmd+=" -c:s:$sub_output_index srt"
        else
            cmd+=" -c:s:$sub_output_index mov_text"
        fi
        cmd+=" -metadata:s:s:$sub_output_index language=dan -metadata:s:s:$sub_output_index title=\"Danish\""
    fi
    
    # Output file
    output="${base}_with_subs.${video##*.}"
    cmd+=" \"$output\""
    
    echo "Running: $cmd"
    eval "$cmd"
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully created: $output"
    else
        echo "✗ Failed to process: $video"
    fi
    echo
done

echo "Done!"
