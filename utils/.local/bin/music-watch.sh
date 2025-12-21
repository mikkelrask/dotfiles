#!/usr/bin/env bash
set -euo pipefail

music_dir="/pool/Music"
declare -A changed_dirs=()
declare -A debounce_timers=()

process_changes() {
    local dir="$1"
    echo "🧠 Kører script for $dir"
    lyrics-fetch "$dir"
    unset debounce_timers["$dir"]
}

schedule_process() {
    local dir="$1"
    # Hvis der allerede er en timer i gang, så gør intet
    if [[ -n "${debounce_timers["$dir"]+set}" ]]; then
        return
    fi

    debounce_timers["$dir"]=1
    (
        sleep 5
        process_changes "$dir"
    ) &
}

inotifywait -m -r -e modify,create,delete,move --format '%w%f' "$music_dir" | while IFS= read -r fullpath; do
    # Ignorer lyrics-filer og logfiler
    case "$fullpath" in
        *.lrc|*.txt|*.log)
            continue
            ;;
    esac

    # Få overordnet mappe
    dir=$(dirname "$fullpath")

    # Ignorer ændringer direkte i root af music_dir (optionelt)
    [[ "$dir" == "$music_dir" ]] && continue

    changed_dirs["$dir"]=1
    schedule_process "$dir"
done
