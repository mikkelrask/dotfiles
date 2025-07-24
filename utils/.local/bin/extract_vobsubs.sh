#!/usr/bin/env bash

shopt -s nullglob

for mp4file in *.mp4; do
    basename="${mp4file%.mp4}"
    temp_mkv="${basename}.temp.mkv"
    vobsub_base="${basename}.danish"
    srt_file="${vobsub_base}.srt"
    output_file="${basename}.dk-subs.mp4"

    echo "🎬 Processing: $mp4file"

    # Step 1: Extract Danish subtitle (assumes stream 0:4 is danish dvd_subtitle)
    echo "📤 Extracting Danish subtitle stream into MKV..."
    ffmpeg -hide_banner -y -i "$mp4file" -map 0:4 -c:s copy "$temp_mkv" || {
        echo "❌ Failed to extract subtitle stream from $mp4file"
        continue
    }

    # Step 2: Extract .idx/.sub using mkvextract
    echo "📦 Extracting VobSub (.sub/.idx)..."
    mkvextract tracks "$temp_mkv" 0:"${vobsub_base}.sub" || {
        echo "❌ Failed to extract VobSub subtitle from $temp_mkv"
        continue
    }

    # Step 3: OCR to .srt
    echo "🔤 Running OCR with vobsub2srt..."
    vobsub2srt "$vobsub_base" || {
        echo "❌ OCR failed for $vobsub_base"
        continue
    }

    # Step 4: Replace subtitle stream with .srt (assumes original sub is 0:4)
    echo "🧼 Removing original subtitle and remuxing with .srt..."
    ffmpeg -hide_banner -y -i "$mp4file" -i "$srt_file" \
        -map 0:v -map 0:a -map 1:0 \
        -c copy -c:s mov_text \
        -metadata:s:s:0 language=dan \
        "$output_file" || {
        echo "❌ Failed to mux SRT into new MP4"
        continue
    }

    echo "✅ Done! Output: $output_file"

    # Cleanup
    rm -f "$temp_mkv" "${vobsub_base}.idx" "${vobsub_base}.sub" "$srt_file"
done

