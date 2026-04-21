#!/bin/bash

# Btrfs Snapshot Backup to NAS (using btrfs send streams)
# Stores true Btrfs snapshots as compressed .btrfs.gz files
# A calm and polite script that only runs when you tell it to.

set -e  # Exit on error

# ===== CONFIGURATION =====
NAS_PATH="/mnt/data/appdata/motoko/btrfs-snapshots"  # Your mounted NAS path
LOCAL_SUBVOLUME="@home"  # The subvolume to backup
SNAPSHOT_DIR="@home/.snapshots"  # Where snapshots live
KEEP_LOCAL=3  # How many snapshots to keep locally after backup
KEEP_NAS=10  # How many snapshot streams to keep on NAS

# ===== FUNCTIONS =====

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if NAS is mounted and writable
check_nas() {
    log "Checking NAS mount..."
    if [ ! -d "${NAS_PATH}" ]; then
        log "ERROR: NAS path ${NAS_PATH} does not exist"
        exit 1
    fi
    if [ ! -w "${NAS_PATH}" ]; then
        log "ERROR: NAS path ${NAS_PATH} is not writable"
        exit 1
    fi
    log "NAS is mounted and writable"
}

# Get list of snapshots, newest first (by numeric ID)
get_snapshots() {
    sudo btrfs subvolume list / | \
        grep "${SNAPSHOT_DIR}" | \
        awk '{print $NF}' | \
        sort -t'/' -k3 -rn
}

# Send snapshot to NAS as .btrfs.gz stream
send_snapshot() {
    local snapshot=$1 # e.g., @home/.snapshots/3/snapshot
    local snapshot_id=$(basename "$(dirname "$snapshot")") # e.g., 3
    local stream_file="${NAS_PATH}/${snapshot_id}.btrfs.gz"

    log "Preparing to send snapshot ${snapshot_id} to NAS..."

    local local_snapshot_abs_path="/$(echo "$snapshot" | sed "s|^${LOCAL_SUBVOLUME}/|home/|")"

    # Make sure snapshot is read-only
    sudo btrfs property set -ts "$local_snapshot_abs_path" ro true || log "WARNING: Failed to mark $local_snapshot_abs_path read-only."

    # If previous snapshot exists, try incremental send
    local prev_snapshot=""
    local all_snapshots=($(get_snapshots))
    for i in "${!all_snapshots[@]}"; do
        if [[ "${all_snapshots[$i]}" == "$snapshot" && $i -lt $((${#all_snapshots[@]} - 1)) ]]; then
            prev_snapshot="${all_snapshots[$((i + 1))]}"
            break
        fi
    done

    if [ -n "$prev_snapshot" ]; then
        log "Incremental send from $(basename $(dirname "$prev_snapshot")) → ${snapshot_id}"
        sudo btrfs send -p "/$(echo "$prev_snapshot" | sed "s|^${LOCAL_SUBVOLUME}/|home/|")" "$local_snapshot_abs_path" | gzip > "$stream_file"
    else
        log "Full send for snapshot ${snapshot_id}"
        sudo btrfs send "$local_snapshot_abs_path" | gzip > "$stream_file"
    fi

    if [ $? -eq 0 ]; then
        log "Snapshot ${snapshot_id} sent successfully to NAS as ${stream_file}"
    else
        log "ERROR: Failed to send snapshot ${snapshot_id}" >&2
        exit 1
    fi
}

# Clean up old local snapshots (keep newest N)
cleanup_local() {
    log "Cleaning up old local snapshots (keeping ${KEEP_LOCAL} newest)..."
    
    local snapshots=($(get_snapshots))
    local count=0
    
    for snapshot in "${snapshots[@]}"; do
        ((count++))
        if [ $count -gt $KEEP_LOCAL ]; then
            local snapshot_name=$(basename "$(dirname "$snapshot")")
            log "Deleting old local snapshot: ${snapshot_name}"
            sudo btrfs subvolume delete "$snapshot" || log "WARNING: Failed to delete $snapshot"
        fi
    done
}

# Clean up old NAS streams (keep newest N)
cleanup_nas() {
    log "Cleaning up old NAS snapshot streams (keeping ${KEEP_NAS} newest)..."
    
    local nas_streams=($(find "${NAS_PATH}" -maxdepth 1 -type f -name "*.btrfs.gz" | sort -Vr))
    local count=0

    for stream_file in "${nas_streams[@]}"; do
        ((count++))
        if [ $count -gt $KEEP_NAS ]; then
            log "Deleting old NAS stream: $(basename "$stream_file")"
            rm -f "$stream_file" || log "WARNING: Failed to delete $stream_file"
        fi
    done

    log "NAS cleanup complete. Kept ${KEEP_NAS} newest snapshots."
}

# ===== MAIN =====

log "=== Btrfs Snapshot Backup to NAS (Send Stream Mode) ==="

# Check prerequisites
if ! command -v btrfs &> /dev/null; then
    log "ERROR: btrfs command not found"
    exit 1
fi

check_nas

# Get current snapshots
snapshots=($(get_snapshots))

if [ ${#snapshots[@]} -eq 0 ]; then
    log "No snapshots found to backup"
    exit 0
fi

log "Found ${#snapshots[@]} snapshot(s) to process"

# Send each snapshot (skip if already backed up)
for snapshot in "${snapshots[@]}"; do
    snapshot_name=$(basename "$(dirname "$snapshot")")
    local_stream_file="${NAS_PATH}/${snapshot_name}.btrfs.gz"

    if [ -f "$local_stream_file" ]; then
        log "Snapshot ${snapshot_name} already backed up on NAS, skipping."
        continue
    fi

    send_snapshot "$snapshot"
done

cleanup_local
cleanup_nas

log "=== Backup complete ==="
log "Local snapshots: $(get_snapshots | wc -l)"
log "NAS snapshot streams: $(find "${NAS_PATH}" -type f -name '*.btrfs.gz' | wc -l)"
