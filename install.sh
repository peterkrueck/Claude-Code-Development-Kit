#!/usr/bin/env bash

# Claude Code Development Kit Remote Installer
#
# This script downloads and installs the Claude Code Development Kit
# Usage: curl -fsSL https://raw.githubusercontent.com/username/repo/main/install.sh | bash

set -euo pipefail

# Configuration
REPO_OWNER="peterkrueck"
REPO_NAME="Claude-Code-Development-Kit"
BRANCH="main"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Spinner function for progress indication
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Print banner
clear
print_color "$BLUE" "╔═══════════════════════════════════════════════╗"
print_color "$BLUE" "║                                               ║"
print_color "$BLUE" "║    🚀 Claude Code Development Kit Installer  ║"
print_color "$BLUE" "║                                               ║"
print_color "$BLUE" "╚═══════════════════════════════════════════════╝"
echo

# Check for required commands
print_color "$YELLOW" "📋 Checking system requirements..."
MISSING_DEPS=""

for cmd in curl tar mktemp; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $cmd"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    print_color "$RED" "❌ Missing required commands:$MISSING_DEPS"
    print_color "$RED" "Please install these before running the installer."
    exit 1
fi

print_color "$GREEN" "✅ System requirements satisfied"
echo

# Create temp directory with cleanup
TEMP_DIR=$(mktemp -d)
cleanup() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        print_color "$YELLOW" "🧹 Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
        print_color "$GREEN" "✅ Cleanup complete"
    fi
}
trap cleanup EXIT INT TERM

# Download framework
print_color "$CYAN" "📥 Downloading Claude Code Development Kit..."
DOWNLOAD_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${BRANCH}"

# Download with progress indication
(
    if ! curl -fsSL "$DOWNLOAD_URL" \
        -H "Accept: application/vnd.github.v3+json" \
        -o "$TEMP_DIR/framework.tar.gz" 2>"$TEMP_DIR/download.log"; then
        echo "DOWNLOAD_FAILED" > "$TEMP_DIR/status"
    else
        echo "DOWNLOAD_SUCCESS" > "$TEMP_DIR/status"
    fi
) &

DOWNLOAD_PID=$!
spinner $DOWNLOAD_PID
wait $DOWNLOAD_PID

# Check download status
if [ -f "$TEMP_DIR/status" ] && [ "$(cat "$TEMP_DIR/status")" = "DOWNLOAD_FAILED" ]; then
    print_color "$RED" "❌ Failed to download framework"
    if [ -f "$TEMP_DIR/download.log" ] && [ -s "$TEMP_DIR/download.log" ]; then
        print_color "$RED" "Error details:"
        cat "$TEMP_DIR/download.log"
    fi
    echo
    print_color "$YELLOW" "Possible solutions:"
    echo "  1. Check your internet connection"
    echo "  2. Verify the repository exists: https://github.com/${REPO_OWNER}/${REPO_NAME}"
    echo "  3. Ensure Claude Code is installed: https://github.com/anthropics/claude-code"
    echo "  4. Try manual installation (git clone)"
    exit 1
fi

# Show download size
if [ -f "$TEMP_DIR/framework.tar.gz" ]; then
    SIZE=$(ls -lh "$TEMP_DIR/framework.tar.gz" | awk '{print $5}')
    print_color "$GREEN" "✅ Download complete (${SIZE}B)"
else
    print_color "$RED" "❌ Download file not found"
    exit 1
fi

# Extract files
echo
print_color "$CYAN" "📦 Extracting framework files..."

# Extract with progress indication
(
    if ! tar -xzf "$TEMP_DIR/framework.tar.gz" -C "$TEMP_DIR" 2>"$TEMP_DIR/extract.log"; then
        echo "EXTRACT_FAILED" > "$TEMP_DIR/extract_status"
    else
        echo "EXTRACT_SUCCESS" > "$TEMP_DIR/extract_status"
    fi
) &

EXTRACT_PID=$!
spinner $EXTRACT_PID
wait $EXTRACT_PID

# Check extraction status
if [ -f "$TEMP_DIR/extract_status" ] && [ "$(cat "$TEMP_DIR/extract_status")" = "EXTRACT_FAILED" ]; then
    print_color "$RED" "❌ Failed to extract framework"
    if [ -f "$TEMP_DIR/extract.log" ] && [ -s "$TEMP_DIR/extract.log" ]; then
        print_color "$RED" "Error details:"
        cat "$TEMP_DIR/extract.log"
    fi
    exit 1
fi

# Find extracted directory (GitHub creates a directory with commit hash)
EXTRACT_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d -name "${REPO_OWNER}-${REPO_NAME}-*" | head -n1)

if [ ! -d "$EXTRACT_DIR" ]; then
    print_color "$RED" "❌ Could not find extracted framework directory"
    print_color "$YELLOW" "Looking in: $TEMP_DIR"
    ls -la "$TEMP_DIR" 2>/dev/null || true
    exit 1
fi

print_color "$GREEN" "✅ Extraction complete"
echo

# Verify setup.sh exists and is executable
if [ ! -f "$EXTRACT_DIR/setup.sh" ]; then
    print_color "$RED" "❌ setup.sh not found in extracted files"
    exit 1
fi

# Make setup.sh executable
chmod +x "$EXTRACT_DIR/setup.sh"

# Change to extract directory and run setup
cd "$EXTRACT_DIR"

print_color "$CYAN" "🔧 Starting framework setup..."
print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Run the actual setup script, passing all arguments
if ! ./setup.sh "$@"; then
    echo
    print_color "$RED" "❌ Setup failed"
    print_color "$YELLOW" "You can try manual installation:"
    echo "  git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
    echo "  cd ${REPO_NAME}"
    echo "  ./setup.sh"
    exit 1
fi

# Success! Cleanup will happen automatically via trap
echo
print_color "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$GREEN" "🎉 Claude Code Development Kit installation complete!"
print_color "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"