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

fetch_for_plain() {
    local artist="$1"
    local album="$2"
    local title_try="$3"
    local out_lrc="$4"

    local lyrics
    lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"

    if [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; then
        local stripped
        stripped="$(echo "$title_try" | sed -E 's/ *\([^)]*\)//g')"
        if [ "$stripped" != "$title_try" ]; then
            title_try="$stripped"
            lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"
        fi
    fi

    if [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; then
        echo "✗ No lyrics for: \"$title_try\""
        return 1
    fi

    echo "$lyrics" | sed -E '/^\[(ar|al|ti):/d' > "$out_lrc"
    echo "✔  Saved lyrics: $(basename "$out_lrc")"
    echo "🤖 Adding lyric metadata for mpd/rmpc"
    return 0
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

    # Strip tracknummer fra søgning – men behold det i filnavn
    TITLE_FOR_SEARCH="$(echo "$TITLE_RAW" | sed -E 's/^[0-9]+[._ -]+//')"

    if [ -f "$LRC_FILE" ]; then
        echo "– Skipping \"$TITLE_RAW\" (already have .lrc)"
        continue
    fi

    if ! fetch_for_plain "$ARTIST" "$ALBUM" "$TITLE_FOR_SEARCH" "$LRC_FILE"; then
        echo "– No lyrics found for \"$TITLE_RAW\""
        continue
    fi
done

echo
echo "Done."
