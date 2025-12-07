#!/bin/bash
#
# bootstrap_mac.sh - Bootstrap script for Mac Media & LLM Stack
#
# This script:
# 1. Verifies macOS version
# 2. Checks for external storage volume
# 3. Installs Homebrew if needed
# 4. Installs required tools
# 5. Creates necessary directories
# 6. Generates .env file
# 7. Sets up Docker Compose stack
# 8. Configures LaunchAgents for autostart
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
DATA_PATH="/Volumes/space"

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check macOS version
check_macos_version() {
    print_info "Checking macOS version..."
    
    # Get macOS version
    macos_version=$(sw_vers -productVersion)
    major_version=$(echo "$macos_version" | cut -d. -f1)
    
    print_info "Detected macOS version: $macos_version"
    
    if [ "$major_version" -lt 15 ]; then
        print_error "This script requires macOS 15 (Sequoia) or later."
        print_error "Your version: $macos_version"
        exit 1
    fi
    
    print_success "macOS version check passed"
}

# Check for external storage
check_storage() {
    print_info "Checking for external storage at $DATA_PATH..."
    
    if [ ! -d "$DATA_PATH" ]; then
        print_error "External storage not found at $DATA_PATH"
        echo ""
        echo "Please ensure your external drive is:"
        echo "  1. Connected to your Mac"
        echo "  2. Mounted at $DATA_PATH"
        echo "  3. Has sufficient space (recommended: 500GB+)"
        echo ""
        echo "You may need to partition and format your drive, then mount it at $DATA_PATH"
        exit 1
    fi
    
    # Check if writable
    if [ ! -w "$DATA_PATH" ]; then
        print_error "Cannot write to $DATA_PATH"
        echo "Please check permissions on the external drive"
        exit 1
    fi
    
    print_success "External storage check passed"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
        return
    fi
    
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    
    print_success "Homebrew installed successfully"
}

# Install required tools
install_tools() {
    print_info "Installing required tools..."
    
    # Install git
    if ! command -v git &> /dev/null; then
        print_info "Installing git..."
        brew install git
    else
        print_success "git is already installed"
    fi
    
    print_success "Required tools installed"
}

# Check Docker Desktop
check_docker() {
    print_info "Checking Docker Desktop..."
    
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        print_success "Docker Desktop is installed and running"
        return
    fi
    
    print_warning "Docker Desktop is not installed or not running"
    echo ""
    echo "Please install Docker Desktop for Mac (Apple Silicon):"
    echo "  1. Visit: https://docs.docker.com/desktop/setup/install/mac-install/"
    echo "  2. Download Docker Desktop for Apple Silicon"
    echo "  3. Install and start Docker Desktop"
    echo "  4. In Docker Desktop → Settings → Resources → File Sharing:"
    echo "     Add '$DATA_PATH' to allowed paths"
    echo "  5. Complete the first-run wizard"
    echo ""
    read -p "Press Enter after installing Docker Desktop to continue..."
    
    # Check again
    if ! command -v docker &> /dev/null || ! docker info &> /dev/null; then
        print_error "Docker Desktop is still not available"
        print_error "Please install Docker Desktop and try again"
        exit 1
    fi
    
    print_success "Docker Desktop is now available"
}

# Create directory structure
create_directories() {
    print_info "Creating directory structure on $DATA_PATH..."
    
    directories=(
        "downloads"
        "movies"
        "tv"
        "music"
        "backup"
        "transmission-config"
        "sonarr-config"
        "radarr-config"
        "plex-config"
        "navidrome-config"
        "lmstudio"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$DATA_PATH/$dir"
        print_info "Created: $DATA_PATH/$dir"
    done
    
    print_success "Directory structure created"
}

# Generate .env file
generate_env() {
    print_info "Generating .env file..."
    
    if [ -f "$SCRIPT_DIR/.env" ]; then
        print_warning ".env file already exists, skipping"
        return
    fi
    
    # Get PUID and PGID
    PUID=$(id -u)
    PGID=$(id -g)
    
    print_info "Detected PUID: $PUID"
    print_info "Detected PGID: $PGID"
    
    # Copy template and replace values
    cp "$SCRIPT_DIR/.env.template" "$SCRIPT_DIR/.env"
    
    # Update with detected values (macOS compatible sed)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^PUID=.*/PUID=$PUID/" "$SCRIPT_DIR/.env"
        sed -i '' "s/^PGID=.*/PGID=$PGID/" "$SCRIPT_DIR/.env"
    else
        sed -i "s/^PUID=.*/PUID=$PUID/" "$SCRIPT_DIR/.env"
        sed -i "s/^PGID=.*/PGID=$PGID/" "$SCRIPT_DIR/.env"
    fi
    
    print_success ".env file generated"
    echo ""
    echo "Note: If you want to set up Plex, get a claim token from:"
    echo "  https://www.plex.tv/claim"
    echo "And add it to .env as PLEX_CLAIM=<your-token>"
}

# Pull and start Docker containers
start_containers() {
    print_info "Pulling Docker images..."
    cd "$SCRIPT_DIR"
    docker compose pull
    
    print_info "Starting Docker containers..."
    docker compose up -d
    
    print_success "Docker containers started"
}

# Setup LaunchAgents
setup_launchagents() {
    print_info "Setting up LaunchAgents for autostart..."
    
    LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_AGENTS_DIR"
    
    # Update paths in plist files and copy to LaunchAgents
    for plist in "$SCRIPT_DIR/launchagents"/*.plist; do
        if [ -f "$plist" ]; then
            filename=$(basename "$plist")
            dest="$LAUNCH_AGENTS_DIR/$filename"
            
            # Copy and replace placeholder paths
            sed "s|__SCRIPT_DIR__|$SCRIPT_DIR|g" "$plist" > "$dest"
            
            # Load the launch agent
            launchctl unload "$dest" 2>/dev/null || true
            launchctl load "$dest"
            
            print_info "Installed: $filename"
        fi
    done
    
    print_success "LaunchAgents configured"
}

# Print access information
print_access_info() {
    echo ""
    echo "======================================================================"
    print_success "Bootstrap completed successfully!"
    echo "======================================================================"
    echo ""
    echo "Access your services at:"
    echo "  • Transmission:  http://localhost:9091"
    echo "  • Sonarr (TV):   http://localhost:8989"
    echo "  • Radarr:        http://localhost:7878"
    echo "  • Plex:          http://localhost:32400/web"
    echo "  • Navidrome:     http://localhost:4533"
    echo ""
    echo "Container management:"
    echo "  • Start:   $SCRIPT_DIR/scripts/start_stack.sh"
    echo "  • Stop:    $SCRIPT_DIR/scripts/stop_stack.sh"
    echo "  • Update:  $SCRIPT_DIR/scripts/update_stack.sh"
    echo "  • Backup:  $SCRIPT_DIR/scripts/backup_configs.sh"
    echo ""
    echo "All data is stored on: $DATA_PATH"
    echo ""
    echo "Next steps:"
    echo "  1. Configure each service through their web interfaces"
    echo "  2. Set up LM Studio (see README.md for details)"
    echo "  3. Configure download clients, indexers, and media libraries"
    echo ""
    echo "For LM Studio setup:"
    echo "  1. Download from: https://lmstudio.ai"
    echo "  2. See README.md for headless/server configuration"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "======================================================================"
    echo "  Mac Media & LLM Stack - Bootstrap Script"
    echo "======================================================================"
    echo ""
    
    check_macos_version
    check_storage
    install_homebrew
    install_tools
    check_docker
    create_directories
    generate_env
    start_containers
    setup_launchagents
    print_access_info
}

# Run main function
main
