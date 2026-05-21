#!/bin/bash

# Script til at finde og oprydde i tomme eller næsten-tomme musikmapper
# Tjekker undermapper i /pool/Music/ for medie-filer

MUSIC_DIR="/pool/Music"
REPORT_MODE=false
TEMP_FILE="/tmp/music_cleanup_candidates_$$"


# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Funktion til at vise hjælp
show_help() {
    echo "Brug: $0 [OPTIONS]"
    echo "Finder og håndterer tomme eller næsten-tomme musikmapper"
    echo ""
    echo "Options:"
    echo "  -r, --report    Kun rapport-mode - viser fundne mapper uden at slette"
    echo "  -h, --help      Viser denne hjælp"
    echo ""
    echo "Scriptet ser efter mapper der kun indeholder:"
    echo "  - .nfo filer"
    echo "  - cover.jpg/cover.png/folder.jpg"
    echo "  - Ingen filer overhovedet"
}

# Parse command line argumenter
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--report)
            REPORT_MODE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Ukendt option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Tjek om musik-directory eksisterer
if [ ! -d "$MUSIC_DIR" ]; then
    echo "Fejl: $MUSIC_DIR eksisterer ikke!"
    exit 1
fi

# Funktion til at tjekke om en album-mappe kun indeholder ikke-medie filer
is_album_empty_or_junk() {
    local dir="$1"
    
    # Tjek om mappen er helt tom
    if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
        return 0  # Tom mappe
    fi
    
    # Find alle filer i mappen (ikke undermapper)
    local files_found=false
    local media_found=false
    
    while IFS= read -r -d '' file; do
        files_found=true
        filename=$(basename "$file")
        lowercase_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
        
        # Tjek om det er en medie-fil (musik, video)
        case "$lowercase_name" in
            *.mp3|*.flac|*.m4a|*.aac|*.ogg|*.wav|*.wma|*.mp4|*.mkv|*.avi|*.m4v)
                media_found=true
                break
                ;;
            *.nfo|*.txt|cover.jpg|cover.png|cover.jpeg|folder.jpg|folder.png|folder.jpeg|albumart.jpg|albumart.png|thumb.jpg|thumb.png|artist.nfo|album.nfo)
                # Disse filer tæller ikke som "indhold"
                continue
                ;;
            *)
                # Andre filer - lad os være forsigtige og beholde mappen
                media_found=true
                break
                ;;
        esac
    done < <(find "$dir" -maxdepth 1 -type f -print0)
    
    # Hvis der ikke blev fundet medie-filer, er mappen "tom"
    if [ "$files_found" = true ] && [ "$media_found" = false ]; then
        return 0  # Kun junk-filer
    elif [ "$files_found" = false ]; then
        return 0  # Helt tom
    else
        return 1  # Indeholder medie-filer
    fi
}

# Funktion til at tjekke om en kunstner-mappe er tom (kun baseret på undermapper)
is_artist_empty() {
    local dir="$1"
    
    # Tjek om der er nogen undermapper (albums)
    local subdir_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
    
    if [ "$subdir_count" -eq 0 ]; then
        return 0  # Ingen undermapper - kunstner-mappen er tom
    else
        return 1  # Der er undermapper - behold mappen
    fi
}

echo "Søger efter tomme eller næsten-tomme mapper i: $MUSIC_DIR"
echo "=================================================="

# Fase 1: Saml alle kandidater
echo "Fase 1: Scanner efter tomme album-mapper..."
album_count=0

# Find alle kunstner-mapper (ét niveau ned fra MUSIC_DIR)
while IFS= read -r -d '' artist_dir; do
    if [ -d "$artist_dir" ]; then
        artist_name=$(basename "$artist_dir")
        
        # Find alle album-mapper (to niveauer ned fra MUSIC_DIR)
        while IFS= read -r -d '' album_dir; do
            if [ -d "$album_dir" ] && is_album_empty_or_junk "$album_dir"; then
                album_name=$(basename "$album_dir")
                echo "ALBUM|$artist_dir|$artist_name|$album_dir|$album_name" >> "$TEMP_FILE"
                album_count=$((album_count + 1))
                echo "  Fundet: $artist_name - $album_name"
            fi
        done < <(find "$artist_dir" -mindepth 1 -maxdepth 1 -type d -print0)
    fi
done < <(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

echo "Fase 2: Scanner efter tomme kunstner-mapper..."
artist_count=0

# Find tomme kunstner-mapper
while IFS= read -r -d '' artist_dir; do
    if [ -d "$artist_dir" ] && is_artist_empty "$artist_dir"; then
        artist_name=$(basename "$artist_dir")
        echo "ARTIST|$artist_dir|$artist_name" >> "$TEMP_FILE"
        artist_count=$((artist_count + 1))
        echo "  Fundet: $artist_name (tom kunstner-mappe)"
    fi
done < <(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

total_found=$((album_count + artist_count))
echo ""
echo "Scanning færdig!"
echo "Fundne tomme album-mapper: $album_count"
echo "Fundne tomme kunstner-mapper: $artist_count"
echo "Total: $total_found"

if [ "$total_found" -eq 0 ]; then
    echo "Ingen tomme mapper fundet - intet at gøre!"
    exit 0
fi

if [ "$REPORT_MODE" = true ]; then
    echo ""
    echo "=== RAPPORT MODE - DETALJER ==="
    
    if [ -f "$TEMP_FILE" ]; then
        while IFS='|' read -r type path1 name1 path2 name2; do
            if [ "$type" = "ALBUM" ]; then
                echo ""
                echo "Tom album-mappe:"
                echo "  Kunstner: $name1"
                echo "  Album: $name2"
                echo "  Sti: $path2"
                echo "  Indhold:"
                if [ -z "$(ls -A "$path2" 2>/dev/null)" ]; then
                    echo "    (Tom mappe)"
                else
                    ls -la "$path2" | tail -n +2 | while IFS= read -r line; do
                        echo "    $line"
                    done
                fi
            elif [ "$type" = "ARTIST" ]; then
                echo ""
                echo "Tom kunstner-mappe:"
                echo "  Kunstner: $name1"
                echo "  Sti: $path1"
                echo "  Indhold:"
                if [ -z "$(ls -A "$path1" 2>/dev/null)" ]; then
                    echo "    (Tom mappe)"
                else
                    ls -la "$path1" | tail -n +2 | while IFS= read -r line; do
                        echo "    $line"
                    done
                fi
            fi
        done < "$TEMP_FILE"
    fi
    
    echo ""
    echo "=== RAPPORT FÆRDIG ==="
    exit 0
fi

# Fase 3: Interaktiv sletning
echo ""
echo "=== INTERAKTIV SLETNING ==="
echo "Tryk Ctrl+C for at afbryde"
echo ""

deleted_count=0

if [ -f "$TEMP_FILE" ]; then
    while IFS='|' read -r type path1 name1 path2 name2; do
        if [ "$type" = "ALBUM" ]; then
            # Tjek om mappen stadig eksisterer (kunne være slettet som del af kunstner-mappe)
            if [ ! -d "$path2" ]; then
                continue
            fi
            
            echo "=== Tom album-mappe ==="
            echo "Kunstner: $name1"
            echo "Album: $name2"
            echo "Sti: $path2"
            echo "Indhold:"
            if [ -z "$(ls -A "$path2" 2>/dev/null)" ]; then
                echo "  (Tom mappe)"
            else
                ls -la "$path2" | tail -n +2 | while IFS= read -r line; do
                    echo "  $line"
                done
            fi
            echo ""
            echo -n "Vil du slette denne album-mappe? (y/N): "
            read -r response </dev/tty
            case "$response" in
                [Yy]|[Yy][Ee][Ss])
                    if rm -rf "$path2"; then
                        echo "✓ Slettet: $path2"
                        deleted_count=$((deleted_count + 1))
                        
                        # Tjek om kunstner-mappen nu er tom
                        if is_artist_empty "$path1"; then
                            echo ""
                            echo "→ Kunstner-mappen '$name1' er nu tom!"
                            echo "Sti: $path1"
                            echo -n "Vil du også slette kunstner-mappen? (y/N): "
                            read -r response2 </dev/tty
                            case "$response2" in
                                [Yy]|[Yy][Ee][Ss])
                                    if rm -rf "$path1"; then
                                        echo "✓ Slettet kunstner-mappe: $path1"
                                        deleted_count=$((deleted_count + 1))
                                    else
                                        echo "✗ Fejl ved sletning af kunstner-mappe: $path1"
                                    fi
                                    ;;
                                *)
                                    echo "- Kunstner-mappe beholdt"
                                    ;;
                            esac
                        fi
                    else
                        echo "✗ Fejl ved sletning af: $path2"
                    fi
                    ;;
                *)
                    echo "- Sprunget over"
                    ;;
            esac
            
        elif [ "$type" = "ARTIST" ]; then
            # Tjek om mappen stadig eksisterer
            if [ ! -d "$path1" ]; then
                continue
            fi
            
            echo "=== Tom kunstner-mappe ==="
            echo "Kunstner: $name1"
            echo "Sti: $path1"
            echo "Indhold:"
            if [ -z "$(ls -A "$path1" 2>/dev/null)" ]; then
                echo "  (Tom mappe)"
            else
                ls -la "$path1" | tail -n +2 | while IFS= read -r line; do
                    echo "  $line"
                done
            fi
            echo ""
            echo -n "Vil du slette denne tomme kunstner-mappe? (y/N): "
            read -r response </dev/tty
            case "$response" in
                [Yy]|[Yy][Ee][Ss])
                    if rm -rf "$path1"; then
                        echo "✓ Slettet kunstner-mappe: $path1"
                        deleted_count=$((deleted_count + 1))
                    else
                        echo "✗ Fejl ved sletning af kunstner-mappe: $path1"
                    fi
                    ;;
                *)
                    echo "- Sprunget over"
                    ;;
            esac
        fi
        
        echo ""
        echo "----------------------------------------"
        echo ""
    done < "$TEMP_FILE"
fi

echo ""
echo "=================================================="
echo "Sammenfatning:"
echo "Fundne kandidater: $total_found"
echo "Slettede mapper: $deleted_count"
echo "Færdig!"
