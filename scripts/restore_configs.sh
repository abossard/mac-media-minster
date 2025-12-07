#!/bin/bash
#
# restore_configs.sh - Restore configuration from backup
#
# Usage: ./restore_configs.sh <backup-file>
#

set -e

DATA_PATH="/Volumes/space"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo -e "${RED}ERROR: No backup file specified${NC}"
    echo ""
    echo "Usage: $0 <backup-file>"
    echo ""
    echo "Available backups:"
    ls -lh "$DATA_PATH/backup"/media-stack-backup_*.tar.gz 2>/dev/null || echo "  (none found)"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}ERROR: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}Restoring from backup...${NC}"
echo "Backup file: $BACKUP_FILE"
echo ""

# Confirm with user
read -p "This will overwrite existing configurations. Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)

echo ""
echo "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

echo "Restoring configurations..."

# Copy all config directories back
if [ -d "$TEMP_DIR/media-stack-configs" ]; then
    for config_dir in "$TEMP_DIR/media-stack-configs"/*; do
        if [ -d "$config_dir" ]; then
            dir_name=$(basename "$config_dir")
            echo "  • Restoring $dir_name"
            
            # Backup existing directory if it exists
            if [ -d "$DATA_PATH/$dir_name" ]; then
                mv "$DATA_PATH/$dir_name" "$DATA_PATH/${dir_name}.old.$(date +%Y%m%d_%H%M%S)"
            fi
            
            # Copy restored directory
            cp -r "$config_dir" "$DATA_PATH/"
        fi
    done
else
    echo -e "${RED}ERROR: Invalid backup format${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✓ Restore completed successfully${NC}"
echo ""
echo "Note: Old configurations have been backed up with .old.* suffix"
echo "You may need to restart the Docker stack:"
echo "  ./scripts/stop_stack.sh"
echo "  ./scripts/start_stack.sh"
