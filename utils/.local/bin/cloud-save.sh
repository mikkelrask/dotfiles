#!/usr/bin/env bash
# cloud-save.sh <push or pull> <save game path> <cloud destination>
set -euo pipefail

MODE="${1:-}"
LOCAL="${2:-}"
CLOUD="${3:-}"

BACKUP_COUNT=5
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

die() {
  echo "❌ $*" >&2
  exit 1
}

notify() {
  if command -v notify-send >/dev/null; then
    notify-send "Heroic Cloud Sync" "$1"
  fi
}

menu() {
  if command -v rofi >/dev/null; then
    echo -e "$1" | rofi -dmenu -i -p "Cloud save conflict"
  else
    notify "$2"
    exit 1
  fi
}

latest_mtime() {
  find "$1" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n1
}

cleanup_backups() {
  local dir="$1"

  find "$dir" -mindepth 1 -maxdepth 1 -type d \
    -printf '%T@ %p\0' |
    sort -z -nr |
    tail -z -n +"$((BACKUP_COUNT + 1))" |
    cut -z -d' ' -f2- |
    xargs -0 -r rm -rf
}

[ -z "$MODE" ] && die "Mode required: push | pull"
[ -z "$LOCAL" ] && die "Local path required"
[ -z "$CLOUD" ] && die "Cloud path required"

[ -d "$LOCAL" ] || die "Local dir does not exist: $LOCAL"
[ -d "$CLOUD" ] || die "Cloud dir does not exist: $CLOUD"

LOCAL_MTIME="$(latest_mtime "$LOCAL")"
CLOUD_MTIME="$(latest_mtime "$CLOUD")"

BACKUP_BASE="$CLOUD/.rsync-backups"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

rsync_common=(
  -a
  --delete
  --backup
  --backup-dir="$BACKUP_DIR"
)

case "$MODE" in
  push)
    if [[ -n "$LOCAL_MTIME" && -n "$CLOUD_MTIME" && "$LOCAL_MTIME" < "$CLOUD_MTIME" ]]; then
      choice=$(menu \
        "Push local → Cloud\nOverwrite local from Cloud\nAbort" \
        "Local saves are older than cloud. Resolve manually.")
      case "$choice" in
        "Push local → Cloud") ;;
        "Overwrite local from Cloud")
          exec "$0" pull "$LOCAL" "$CLOUD"
          ;;
        *) exit 0 ;;
      esac
    fi

    rsync "${rsync_common[@]}" "$LOCAL/" "$CLOUD/"
    cleanup_backups "$BACKUP_BASE"
    ;;

  pull)
    if [[ -n "$LOCAL_MTIME" && -n "$CLOUD_MTIME" && "$LOCAL_MTIME" > "$CLOUD_MTIME" ]]; then
      choice=$(menu \
        "Overwrite local from Cloud\nPush local → Cloud\nAbort" \
        "Local saves are newer than cloud. Resolve manually.")
      case "$choice" in
        "Overwrite local from Cloud") ;;
        "Push local → Cloud")
          exec "$0" push "$LOCAL" "$CLOUD"
          ;;
        *) exit 0 ;;
      esac
    fi

    rsync "${rsync_common[@]}" "$CLOUD/" "$LOCAL/"
    cleanup_backups "$BACKUP_BASE"
    ;;

  *)
    die "Unknown mode: $MODE"
    ;;
esac
