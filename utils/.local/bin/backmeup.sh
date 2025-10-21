#!/usr/bin/env bash

# Production NAS to Backup NAS sync script
# Runs ON: ava
# Syncs TO: delos
#
# Usage: backmeup [--dry-run]

# 1. Generate timestamp once for consistent naming
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Configuration
BACKUP_HOST="raske@delos"  # Backup server hostname
SOURCE_PATH="/home/mr/"  # Local source path on THIS (prod) server
BACKUP_PATH="/data/appdata/ava/home/mr/"  # Destination path on backup server
BACKUP_VERSIONS_PATH="/data/appdata/ava/Backup/Versions/$TIMESTAMP"  # Versioned backups (on remote)
LOG_DIR="/home/mr/.local/share/backmeup/"
LOG_FILE="$LOG_DIR/sync_$TIMESTAMP.log"
LOCK_FILE="/tmp/nas_sync.lock"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 2. Check for dry-run flag
DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

# 3. Check if backup host is reachable
BACKUP_HOST_NAME=$(echo "$BACKUP_HOST" | cut -d'@' -f2)
if echo "$BACKUP_HOST" | grep -q '@'; then
    # Has user@host format
    PING_TARGET="$BACKUP_HOST_NAME"
else
    # Just hostname
    PING_TARGET="$BACKUP_HOST"
fi

if ! ping -c 1 -W 2 "$PING_TARGET" >/dev/null 2>&1; then
    log "ERROR: Could not communicate with backup server: $BACKUP_HOST"
    log "ERROR: Please make sure the server is turned on and reachable"
    exit 1
fi

# 4. Create backup version directory on remote server
log "Creating version directory on backup server..."
ssh "$BACKUP_HOST" "mkdir -pv '$BACKUP_VERSIONS_PATH'" 2>&1 | tee -a "$LOG_FILE"
if [ $? -ne 0 ]; then
    log "ERROR: Could not create version directory on backup server"
    exit 1
fi

# Check if another sync is running
if [ -f "$LOCK_FILE" ]; then
    log "ERROR: Another sync is already running (lock file exists)"
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Trap to ensure lock file is removed on exit
trap "rm -f $LOCK_FILE" EXIT

log "=== Production to Backup Sync ==="
if [ "$DRY_RUN" = true ]; then
    log "*** DRY-RUN MODE ENABLED - No actual changes will be made ***"
fi
log "Running on: $(hostname)"
log "Source (local): $SOURCE_PATH"
log "Destination (remote): $BACKUP_HOST:$BACKUP_PATH"
log "Versions stored in: $BACKUP_HOST:$BACKUP_VERSIONS_PATH"
log ""

# Step 1: Dry-run to see what would be transferred
log "=== DRY RUN: Analyzing changes ==="
log ""

rsync -avhn \
    --stats \
    --backup \
    --backup-dir="$BACKUP_VERSIONS_PATH" \
    --exclude '.DS_Store' \
    --exclude '.SoulseekQt' \
    --exclude 'node_modules' \
    --exclude '.cache' \
    --exclude '.cargo' \
    --exclude '.e4mc_cache' \
    --exclude '.gemini' \
    --exclude '.gradle' \
    --exclude '.java' \
    --exclude '.librewolf' \
    --exclude '.local' \
    --exclude '.lyrics' \
    --exclude '.mozilla' \
    --exclude '.npm' \
    --exclude '.npm-global' \
    --exclude '.ollama' \
    --exclude '.pki' \
    --exclude '.steamid' \
    --exclude '.steampath' \
    --exclude '.themes' \
    --exclude '.thunderbird' \
    --exclude '.var' \
    --exclude 'Music' \
    --exclude 'Repos' \
    --exclude 'Thumbs.db' \
    --exclude '.Trash-*' \
    --exclude '@eaDir/' \
    "$SOURCE_PATH" \
    "$BACKUP_HOST:$BACKUP_PATH" \
    2>&1 | tee -a "$LOG_FILE"

DRYRUN_EXIT=$?

if [ $DRYRUN_EXIT -ne 0 ]; then
    log ""
    log "ERROR: Dry-run failed with exit code $DRYRUN_EXIT"
    log "Aborting sync. Please check connection to $BACKUP_HOST"
    exit $DRYRUN_EXIT
fi

log ""
log "=== Dry-run complete. Starting actual sync... ==="
log ""

# Step 2: Actual sync (skip if --dry-run flag was used)
if [ "$DRY_RUN" = true ]; then
    log "*** DRY-RUN MODE: Skipping actual sync ***"
    rm -f "$LOCK_FILE"
    exit 0
fi

rsync -avh \
    --progress \
    --stats \
    --backup \
    --backup-dir="$BACKUP_VERSIONS_PATH" \
    --exclude '.DS_Store' \
    --exclude '.SoulseekQt' \
    --exclude 'node_modules' \
    --exclude '.cache' \
    --exclude '.cargo' \
    --exclude '.e4mc_cache' \
    --exclude '.gemini' \
    --exclude '.gradle' \
    --exclude '.java' \
    --exclude '.librewolf' \
    --exclude '.local' \
    --exclude '.lyrics' \
    --exclude '.mozilla' \
    --exclude '.npm' \
    --exclude '.npm-global' \
    --exclude '.ollama' \
    --exclude '.pki' \
    --exclude '.steamid' \
    --exclude '.steampath' \
    --exclude '.themes' \
    --exclude '.thunderbird' \
    --exclude '.var' \
    --exclude 'Music' \
    --exclude 'Repos' \
    --exclude 'Thumbs.db' \
    --exclude '.Trash-*' \
    --exclude '@eaDir/' \
    "$SOURCE_PATH" \
    "$BACKUP_HOST:$BACKUP_PATH" \
    2>&1 | tee -a "$LOG_FILE"

# Capture rsync exit status
RSYNC_EXIT=$?

log ""
if [ $RSYNC_EXIT -eq 0 ]; then
    log "=== Sync completed successfully ==="
else
    log "ERROR: Sync failed with exit code $RSYNC_EXIT"
    # Optional: send alert (email, webhook, etc.)
fi

# Keep only last 30 days of logs
find "$LOG_DIR" -name "sync_*.log" -mtime +30 -delete 2>/dev/null

log "Log cleanup completed"

# Keep only last 90 days of file versions (adjust retention as needed)
log "Cleaning up old file versions (keeping last 90 days)..."
ssh "$BACKUP_HOST" "find $BACKUP_PATH/Backup/Versions/ -maxdepth 1 -type d -mtime +90 -exec rm -rf {} +" 2>/dev/null

log "Version cleanup completed"

exit $RSYNC_EXIT
