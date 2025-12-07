#!/bin/bash
#
# lmstudio_server_login.sh - Start LM Studio server in headless mode
#
# This script is designed to be run at login via LaunchAgent
# or manually to start the LM Studio server
#

# Path to LM Studio CLI (configurable via environment variable)
LMS_CLI="${LMS_CLI_PATH:-/Applications/LM Studio.app/Contents/Resources/lms}"

# Alternative paths to try if default doesn't exist
LMS_CLI_ALTERNATIVES=(
    "/Applications/LM Studio.app/Contents/Resources/lms"
    "$HOME/Applications/LM Studio.app/Contents/Resources/lms"
)

# Log file
LOG_FILE="$HOME/Library/Logs/lmstudio-server.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

{
    echo "==================================================================="
    echo "LM Studio Server startup at: $(date)"
    echo "==================================================================="
    
    # Check if LM Studio CLI exists at configured path
    if [ ! -f "$LMS_CLI" ]; then
        echo "LM Studio CLI not found at: $LMS_CLI"
        echo "Trying alternative paths..."
        
        # Try alternative paths
        found=false
        for alt_path in "${LMS_CLI_ALTERNATIVES[@]}"; do
            if [ -f "$alt_path" ]; then
                echo "Found LM Studio CLI at: $alt_path"
                LMS_CLI="$alt_path"
                found=true
                break
            fi
        done
        
        if [ "$found" = false ]; then
            echo "ERROR: LM Studio CLI not found in any known location"
            echo "Please ensure LM Studio is installed in /Applications"
            echo "Or set LMS_CLI_PATH environment variable to the correct path"
            exit 1
        fi
    fi
    
    echo "Using LM Studio CLI: $LMS_CLI"
    echo "Starting LM Studio server..."
    
    # Start the server
    # The server will continue running in the background
    "$LMS_CLI" server start
    
    echo "LM Studio server started successfully"
    echo "Server should be available at http://localhost:1234"
    echo "(Check LM Studio documentation for exact port configuration)"
    
} >> "$LOG_FILE" 2>&1
