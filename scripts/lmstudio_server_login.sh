#!/bin/bash
#
# lmstudio_server_login.sh - Start LM Studio server in headless mode
#
# This script is designed to be run at login via LaunchAgent
# or manually to start the LM Studio server
#

# Path to LM Studio CLI (adjust if needed)
LMS_CLI="/Applications/LM Studio.app/Contents/Resources/lms"

# Log file
LOG_FILE="$HOME/Library/Logs/lmstudio-server.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

{
    echo "==================================================================="
    echo "LM Studio Server startup at: $(date)"
    echo "==================================================================="
    
    # Check if LM Studio CLI exists
    if [ ! -f "$LMS_CLI" ]; then
        echo "ERROR: LM Studio CLI not found at: $LMS_CLI"
        echo "Please ensure LM Studio is installed in /Applications"
        exit 1
    fi
    
    echo "Starting LM Studio server..."
    
    # Start the server
    # The server will continue running in the background
    "$LMS_CLI" server start
    
    echo "LM Studio server started successfully"
    echo "Server should be available at http://localhost:1234"
    echo "(Check LM Studio documentation for exact port configuration)"
    
} >> "$LOG_FILE" 2>&1
