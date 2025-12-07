#!/bin/bash
#
# verify_setup.sh - Verify the installation and setup
#
# This script checks that all prerequisites are met before running the bootstrap
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
DATA_PATH="/Volumes/space"
CHECKS_PASSED=0
CHECKS_FAILED=0

print_header() {
    echo ""
    echo "======================================================================"
    echo "  Mac Media & LLM Stack - Setup Verification"
    echo "======================================================================"
    echo ""
}

check_item() {
    local name="$1"
    local command="$2"
    
    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_version() {
    local name="$1"
    local command="$2"
    
    version=$($command 2>&1 || echo "not found")
    if [ "$version" != "not found" ]; then
        echo -e "${GREEN}✓${NC} $name: $version"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name: not found"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Main checks
print_header

echo "System Checks:"
echo "─────────────────────────────────────────"

# macOS version
macos_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
major_version=$(echo "$macos_version" | cut -d. -f1)
if [ "$major_version" -ge 15 ]; then
    echo -e "${GREEN}✓${NC} macOS version: $macos_version (Sequoia or later)"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗${NC} macOS version: $macos_version (requires 15.0+)"
    ((CHECKS_FAILED++))
fi

# Architecture
arch=$(uname -m)
if [ "$arch" = "arm64" ]; then
    echo -e "${GREEN}✓${NC} Architecture: $arch (Apple Silicon)"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠${NC} Architecture: $arch (not Apple Silicon, may work)"
    ((CHECKS_PASSED++))
fi

echo ""
echo "Storage Checks:"
echo "─────────────────────────────────────────"

# External drive
if [ -d "$DATA_PATH" ]; then
    if [ -w "$DATA_PATH" ]; then
        space=$(df -h "$DATA_PATH" | tail -1 | awk '{print $4}')
        echo -e "${GREEN}✓${NC} External drive: $DATA_PATH (available: $space)"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗${NC} External drive: $DATA_PATH (not writable)"
        ((CHECKS_FAILED++))
    fi
else
    echo -e "${RED}✗${NC} External drive: $DATA_PATH (not found)"
    ((CHECKS_FAILED++))
fi

echo ""
echo "Software Checks:"
echo "─────────────────────────────────────────"

# Homebrew
check_version "Homebrew" "brew --version | head -1"

# Git
check_version "Git" "git --version"

# Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null 2>&1; then
        docker_version=$(docker --version)
        echo -e "${GREEN}✓${NC} Docker: $docker_version (running)"
        ((CHECKS_PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Docker: installed but not running"
        ((CHECKS_FAILED++))
    fi
else
    echo -e "${RED}✗${NC} Docker: not installed"
    ((CHECKS_FAILED++))
fi

# Docker Compose
check_version "Docker Compose" "docker compose version"

echo ""
echo "Repository Checks:"
echo "─────────────────────────────────────────"

# Required files
check_item "docker-compose.yml" "test -f '$SCRIPT_DIR/docker-compose.yml'"
check_item ".env.template" "test -f '$SCRIPT_DIR/.env.template'"
check_item "README.md" "test -f '$SCRIPT_DIR/README.md'"
check_item "bootstrap script" "test -x '$SCRIPT_DIR/scripts/bootstrap_mac.sh'"
check_item "start script" "test -x '$SCRIPT_DIR/scripts/start_stack.sh'"
check_item "stop script" "test -x '$SCRIPT_DIR/scripts/stop_stack.sh'"

echo ""
echo "Optional Software:"
echo "─────────────────────────────────────────"

# LM Studio
if [ -d "/Applications/LM Studio.app" ]; then
    echo -e "${GREEN}✓${NC} LM Studio: installed"
else
    echo -e "${YELLOW}○${NC} LM Studio: not installed (optional)"
fi

# Summary
echo ""
echo "======================================================================"
echo "Summary:"
echo "  Passed: $CHECKS_PASSED"
echo "  Failed: $CHECKS_FAILED"
echo "======================================================================"

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Ready to run bootstrap_mac.sh${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please resolve issues before running bootstrap.${NC}"
    echo ""
    echo "Next steps:"
    if ! command -v docker &> /dev/null || ! docker info &> /dev/null 2>&1; then
        echo "  1. Install Docker Desktop: https://docs.docker.com/desktop/setup/install/mac-install/"
    fi
    if [ ! -d "$DATA_PATH" ]; then
        echo "  2. Mount external drive at $DATA_PATH"
    fi
    exit 1
fi
