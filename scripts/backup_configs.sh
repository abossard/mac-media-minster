#!/bin/bash
#
# backup_configs.sh - Backup all configuration directories
#

set -e

DATA_PATH="/Volumes/space"
BACKUP_DIR="$DATA_PATH/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/media-stack-backup_$TIMESTAMP.tar.gz"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting backup...${NC}"
echo "Timestamp: $TIMESTAMP"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Configuration directories to backup
CONFIG_DIRS=(
    "transmission-config"
    "sonarr-config"
    "radarr-config"
    "plex-config"
    "navidrome-config"
)

# Create temporary directory for backup staging
TEMP_DIR=$(mktemp -d)
BACKUP_STAGE="$TEMP_DIR/media-stack-configs"
mkdir -p "$BACKUP_STAGE"

echo ""
echo "Copying configurations..."

# Copy each config directory
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DATA_PATH/$dir" ]; then
        echo "  • $dir"
        cp -r "$DATA_PATH/$dir" "$BACKUP_STAGE/"
    else
        echo "  ⚠ Skipping $dir (not found)"
    fi
done

# Include LM Studio config if it exists
if [ -d "$DATA_PATH/lmstudio" ]; then
    echo "  • lmstudio"
    cp -r "$DATA_PATH/lmstudio" "$BACKUP_STAGE/"
fi

echo ""
echo "Creating compressed archive..."
tar -czf "$BACKUP_FILE" -C "$TEMP_DIR" "media-stack-configs"

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

# Get backup size
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

echo ""
echo -e "${GREEN}✓ Backup completed successfully${NC}"
echo "  Location: $BACKUP_FILE"
echo "  Size: $BACKUP_SIZE"
echo ""
echo "To restore this backup, run:"
echo "  ./scripts/restore_configs.sh $BACKUP_FILE"

# Keep only last 10 backups
echo ""
echo "Cleaning old backups (keeping last 10)..."
cd "$BACKUP_DIR"
backup_count=$(ls -t media-stack-backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$backup_count" -gt 10 ]; then
    ls -t media-stack-backup_*.tar.gz | tail -n +11 | while read -r old_backup; do
        echo "  Removing old backup: $old_backup"
        rm -f "$old_backup"
    done
fi
echo "Cleanup complete"
