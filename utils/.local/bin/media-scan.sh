#!/bin/bash

# Media Codec Analysis Script
# Scans media directories and reports non-H.264 files

# Configuration
MEDIA_DIRS=(
    "/pool/Movies"
    "/pool/TV Shows"
)

OUTPUT_FILE="non_h264_report.csv"

# Initialize CSV with headers
echo "File Path,Container,Video Codec,Resolution,File Size (MB),Audio Codec,Audio Channels" > "$OUTPUT_FILE"

echo "Scanning for non-H.264 files..."
echo "This may take a while for large libraries..."
echo ""

total_files=0
non_h264_files=0
total_size_mb=0

# Function to process a single file
process_file() {
    local file="$1"
    
    # Get file info using ffprobe
    local probe_output
    probe_output=$(ffprobe -v quiet -print_format json -show_format -show_streams "$file" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Warning: Could not analyze $file"
        return
    fi
    
    # Extract video codec
    local video_codec
    video_codec=$(echo "$probe_output" | jq -r '.streams[] | select(.codec_type=="video") | .codec_name' | head -1)
    
    # Skip if no video stream or if it's already H.264
    if [ -z "$video_codec" ] || [ "$video_codec" = "h264" ]; then
        return
    fi
    
    # Get additional info
    local container="${file##*.}"
    local resolution
    resolution=$(echo "$probe_output" | jq -r '.streams[] | select(.codec_type=="video") | "\(.width)x\(.height)"' | head -1)
    
    local file_size_bytes
    file_size_bytes=$(echo "$probe_output" | jq -r '.format.size // 0')
    local file_size_mb=$((file_size_bytes / 1024 / 1024))
    
    local audio_codec
    audio_codec=$(echo "$probe_output" | jq -r '.streams[] | select(.codec_type=="audio") | .codec_name' | head -1)
    
    local audio_channels
    audio_channels=$(echo "$probe_output" | jq -r '.streams[] | select(.codec_type=="audio") | .channels' | head -1)
    
    # Add to CSV
    echo "\"$file\",$container,$video_codec,$resolution,$file_size_mb,$audio_codec,$audio_channels" >> "$OUTPUT_FILE"
    
    ((non_h264_files++))
    total_size_mb=$((total_size_mb + file_size_mb))
    
    echo "Found: $(basename "$file") [$video_codec, ${file_size_mb}MB]"
}

# Main scanning loop
for media_dir in "${MEDIA_DIRS[@]}"; do
    if [ ! -d "$media_dir" ]; then
        echo "Warning: Directory $media_dir not found, skipping..."
        continue
    fi
    
    echo "Scanning: $media_dir"
    
    # Find all video files and process them
    while IFS= read -r -d '' file; do
        ((total_files++))
        process_file "$file"
    done < <(find "$media_dir" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" \) -print0)
done

# Generate summary
echo ""
echo "=========================================="
echo "SCAN COMPLETE"
echo "=========================================="
echo "Total files scanned: $total_files"
echo "Non-H.264 files found: $non_h264_files"
echo "Total size of non-H.264 files: ${total_size_mb}MB (~$((total_size_mb / 1024))GB)"
echo ""
echo "Detailed report saved to: $OUTPUT_FILE"
echo ""

# Show top codecs by count
if [ $non_h264_files -gt 0 ]; then
    echo "Most common non-H.264 codecs:"
    tail -n +2 "$OUTPUT_FILE" | cut -d',' -f3 | sort | uniq -c | sort -nr | head -10
    echo ""
    
    echo "Largest files (top 10):"
    tail -n +2 "$OUTPUT_FILE" | sort -t',' -k5 -nr | head -10 | while IFS=',' read -r path container codec res size audio_codec channels; do
        echo "  $(basename "$path") - $codec - ${size}MB"
    done
fi
