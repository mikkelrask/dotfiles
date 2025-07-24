#!/usr/bin/env bash
set -euo pipefail

LRCLIB_API="https://lrclib.net/api/get"

if [ $# -ne 1 ]; then
    echo "Usage: $0 \"/path/to/Artist/Album\""
    exit 1
fi

ALBUM_DIR="$1"
if [ ! -d "$ALBUM_DIR" ]; then
    echo "Error: '$ALBUM_DIR' is not a directory."
    exit 1
fi

ARTIST="$(basename "$(dirname "$ALBUM_DIR")")"
ALBUM="$(basename "$ALBUM_DIR")"

LYRICS_LINK_BASE="/home/mr/.config/mpd/lyrics"

get_lyrics_for() {
    local artist="$1"
    local album="$2"
    local title_try="$3"

    curl -sG \
        --data-urlencode "artist_name=${artist}" \
        --data-urlencode "track_name=${title_try}" \
        --data-urlencode "album_name=${album}" \
        "$LRCLIB_API" \
        | jq -r '.syncedLyrics'
}

prepend_lrc_tags() {
    local artist="$1"
    local album="$2"
    local title="$3"
    local lrc_file="$4"

    if ! grep -q '^\[ar:' "$lrc_file"; then
        local tmpfile
        tmpfile="$(mktemp)"
        {
            echo "[ar:$artist]"
            echo "[ti:$title]"
            echo "[al:$album]"
            cat "$lrc_file"
        } > "$tmpfile"
        mv "$tmpfile" "$lrc_file"
        echo "→ Prepended metadata tags to: $lrc_file"
    fi
}

fetch_for_plain() {
    local artist="$1"
    local album="$2"
    local title_try="$3"
    local out_lrc="$4"

    local lyrics
    lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"

    if [[ "$title_try" == *"("* ]] && { [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; }; then
        local stripped
        stripped="$(echo "$title_try" | sed -E 's/ *\([^)]*\)//g')"
        lyrics="$(get_lyrics_for "$artist" "$album" "$stripped")"
        title_try="$stripped"
    fi

    if [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; then
        echo "✗ No lyrics for: \"$title_try\""
        return 1
    fi

    echo "$lyrics" | sed -E '/^\[(ar|al|ti):/d' > "$out_lrc"
    echo "✔ Saved lyrics: $(basename "$out_lrc")"
    return 0
}

symlink_lyrics() {
    local artist="$1"
    local title_search="$2"  # ren titel uden nummer
    local src_lrc="$3"

    local dest_dir="${LYRICS_LINK_BASE}/${artist}"
    local dest_lrc="${dest_dir}/${title_search}.lrc"

    mkdir -p "$dest_dir"
    if [ -e "$dest_lrc" ]; then
        rm -f "$dest_lrc"
    fi
    ln -s "$src_lrc" "$dest_lrc"
    echo "→ Symlink created: $dest_lrc → $src_lrc"
}

echo "▶ Fetching lyrics for all supported files in: $ALBUM_DIR"
echo "  Artist: $ARTIST"
echo "  Album:  $ALBUM"
echo

shopt -s nullglob
for file in "$ALBUM_DIR"/*.{mp3,flac,m4a,opus}; do
    [ -e "$file" ] || continue

    BASENAME="$(basename "$file")"
    TITLE_RAW="${BASENAME%.*}"  # fx "01. Track Name"
    LRC_FILE="${file%.*}.lrc"

    # Strip tracknummer fra søgning og til symlink-navn – men behold det i albummappen
    TITLE_FOR_SEARCH="$(echo "$TITLE_RAW" | sed -E 's/^[0-9]+[._ -]+//')"

    if [ -f "$LRC_FILE" ]; then
        echo "– Skipping \"$TITLE_RAW\" (already have .lrc)"
        prepend_lrc_tags "$ARTIST" "$ALBUM" "$TITLE_FOR_SEARCH" "$LRC_FILE"
        symlink_lyrics "$ARTIST" "$TITLE_FOR_SEARCH" "$LRC_FILE"
        continue
    fi

    if fetch_for_plain "$ARTIST" "$ALBUM" "$TITLE_FOR_SEARCH" "$LRC_FILE"; then
        prepend_lrc_tags "$ARTIST" "$ALBUM" "$TITLE_FOR_SEARCH" "$LRC_FILE"
        symlink_lyrics "$ARTIST" "$TITLE_FOR_SEARCH" "$LRC_FILE"
    else
        echo "– No lyrics found for \"$TITLE_FOR_SEARCH\""
    fi
done

echo
echo "Done."
