#!/bin/bash
#
# stop_stack.sh - Stop the Docker Compose media stack
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

echo "Stopping media stack..."
cd "$SCRIPT_DIR"

# Stop containers
docker compose down

echo "Media stack stopped successfully"
