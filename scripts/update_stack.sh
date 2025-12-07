#!/bin/bash
#
# update_stack.sh - Update all Docker containers to latest versions
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/update_$TIMESTAMP.log"

echo "Updating media stack..."
echo "Log file: $LOG_FILE"

cd "$SCRIPT_DIR"

{
    echo "==================================================================="
    echo "Update started at: $(date)"
    echo "==================================================================="
    echo ""
    
    echo "Pulling latest images..."
    docker compose pull
    
    echo ""
    echo "Recreating containers with new images..."
    docker compose up -d
    
    echo ""
    echo "Cleaning up old images..."
    docker image prune -f
    
    echo ""
    echo "==================================================================="
    echo "Update completed at: $(date)"
    echo "==================================================================="
} 2>&1 | tee "$LOG_FILE"

echo ""
echo "Update completed successfully"
echo "Log saved to: $LOG_FILE"
