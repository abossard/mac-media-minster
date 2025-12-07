#!/bin/bash
#
# start_stack.sh - Start the Docker Compose media stack
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

echo "Starting media stack..."
cd "$SCRIPT_DIR"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found"
    echo "Please run scripts/bootstrap_mac.sh first"
    exit 1
fi

# Start containers
docker compose up -d

echo "Media stack started successfully"
echo ""
echo "Access your services at:"
echo "  • Transmission:  http://localhost:9091"
echo "  • Sonarr (TV):   http://localhost:8989"
echo "  • Radarr:        http://localhost:7878"
echo "  • Plex:          http://localhost:32400/web"
echo "  • Navidrome:     http://localhost:4533"
