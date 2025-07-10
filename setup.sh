#!/usr/bin/env bash

# AI Development Framework Setup Script
# 
# This script installs the AI Development Framework into a target project,
# providing automated context management and multi-agent workflows for Claude Code.

set -euo pipefail

# Script directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read version from VERSION file if it exists
if [ -f "$SCRIPT_DIR/VERSION" ]; then
    VERSION=$(cat "$SCRIPT_DIR/VERSION" | tr -d '\n')
else
    VERSION=""
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration variables
TARGET_DIR=""
INSTALL_CONTEXT7="n"
INSTALL_GEMINI="n"
INSTALL_NOTIFICATIONS="n"
OS=""
AUDIO_PLAYER=""
OVERWRITE_ALL="n"
SKIP_ALL="n"

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Print header
print_header() {
    echo
    print_color "$BLUE" "==========================================="
    if [ -n "$VERSION" ]; then
        print_color "$BLUE" "   AI Development Framework Setup v$VERSION"
    else
        print_color "$BLUE" "   AI Development Framework Setup"
    fi
    print_color "$BLUE" "==========================================="
    echo
}

# Check if Claude Code is installed
check_claude_code() {
    print_color "$YELLOW" "Checking prerequisites..."
    
    if ! command -v claude &> /dev/null; then
        print_color "$RED" "❌ Claude Code is not installed or not in PATH"
        echo "Please install Claude Code from: https://github.com/anthropics/claude-code"
        echo "After installation, make sure 'claude' command is available in your terminal"
        exit 1
    fi
    
    print_color "$GREEN" "✓ Claude Code is installed"
}

# Check for required tools
check_required_tools() {
    local missing_tools=()
    
    for tool in jq grep cat mkdir cp chmod; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_color "$RED" "❌ Missing required tools: ${missing_tools[*]}"
        echo
        echo "These tools are needed for:"
        echo "  • jq     - Parse and generate JSON configuration files"
        echo "  • grep   - Search and filter file contents"
        echo "  • cat    - Read and display files"
        echo "  • mkdir  - Create directory structure"
        echo "  • cp     - Copy framework files"
        echo "  • chmod  - Set executable permissions on scripts"
        echo
        echo "On macOS: Most are pre-installed, install jq with: brew install jq"
        echo "On Ubuntu/Debian: sudo apt-get install ${missing_tools[*]}"
        echo "On other systems: Use your package manager to install these tools"
        exit 1
    fi
    
    print_color "$GREEN" "✓ All required tools are available"
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            AUDIO_PLAYER="afplay"
            ;;
        Linux*)
            OS="Linux"
            # Check for available audio players
            for player in paplay aplay pw-play play ffplay; do
                if command -v "$player" &> /dev/null; then
                    AUDIO_PLAYER="$player"
                    break
                fi
            done
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="Windows"
            AUDIO_PLAYER="powershell"
            ;;
        *)
            OS="Unknown"
            AUDIO_PLAYER=""
            ;;
    esac
    
    print_color "$GREEN" "✓ Detected OS: $OS"
}

# Get target directory
get_target_directory() {
    echo
    print_color "$YELLOW" "Where would you like to install the AI Development Framework?"
    echo "Enter target project directory (or . for current directory):"
    read -r input_dir
    
    if [ "$input_dir" = "." ]; then
        TARGET_DIR="$(pwd)"
    else
        TARGET_DIR="$(cd "$input_dir" 2>/dev/null && pwd)" || {
            print_color "$RED" "❌ Directory '$input_dir' does not exist"
            exit 1
        }
    fi
    
    # Check if target is the framework source directory
    if [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
        print_color "$RED" "❌ Cannot install framework into its own source directory"
        echo "Please choose a different target directory"
        exit 1
    fi
    
    print_color "$GREEN" "✓ Target directory: $TARGET_DIR"
}

# Prompt for optional components
prompt_optional_components() {
    echo
    print_color "$YELLOW" "Optional Components:"
    echo
    
    # Context7 MCP
    print_color "$CYAN" "Context7 MCP Server (Highly Recommended)"
    echo "  Provides up-to-date documentation for external libraries (React, FastAPI, etc.)"
    echo -n "  Install Context7 integration? (y/n): "
    read -r INSTALL_CONTEXT7
    echo
    
    # Gemini MCP
    print_color "$CYAN" "Gemini Assistant MCP Server (Highly Recommended)"
    echo "  Enables architectural consultation and advanced code review capabilities"
    echo -n "  Install Gemini integration? (y/n): "
    read -r INSTALL_GEMINI
    echo
    
    # Notifications
    print_color "$CYAN" "Notification System (Convenience Feature)"
    echo "  Plays audio alerts when tasks complete or input is needed"
    echo -n "  Set up notification hooks? (y/n): "
    read -r INSTALL_NOTIFICATIONS
    
    # Only detect OS if notifications are enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        detect_os
        if [ -z "$AUDIO_PLAYER" ] && [ "$OS" = "Linux" ]; then
            print_color "$YELLOW" "⚠️  No audio player found. Install one of: paplay, aplay, pw-play, play, ffplay"
        fi
    fi
}

# Create directory structure
create_directories() {
    print_color "$YELLOW" "Creating directory structure..."
    
    # Main directories
    mkdir -p "$TARGET_DIR/commands"
    mkdir -p "$TARGET_DIR/hooks/config"
    mkdir -p "$TARGET_DIR/docs/ai-context"
    mkdir -p "$TARGET_DIR/docs/open-issues"
    mkdir -p "$TARGET_DIR/docs/specs"
    mkdir -p "$TARGET_DIR/logs"
    mkdir -p "$TARGET_DIR/.claude"
    
    # Only create sounds directory if notifications are enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        mkdir -p "$TARGET_DIR/hooks/sounds"
    fi
    
    print_color "$GREEN" "✓ Directory structure created"
}

# Helper function to handle file conflicts
handle_file_conflict() {
    local source_file="$1"
    local dest_file="$2"
    local file_type="$3"
    
    # If policies are already set, apply them
    if [ "$OVERWRITE_ALL" = "y" ]; then
        cp "$source_file" "$dest_file"
        return 0
    elif [ "$SKIP_ALL" = "y" ]; then
        return 1
    fi
    
    # Show conflict and ask user
    print_color "$YELLOW" "⚠️  File already exists: $(basename "$dest_file")"
    echo "   Type: $file_type"
    echo "   Location: $dest_file"
    echo
    echo "   Options:"
    echo "   [o] Overwrite this file"
    echo "   [s] Skip this file"
    echo "   [a] Overwrite all remaining files"
    echo "   [n] Skip all remaining files"
    echo
    echo -n "   Your choice (o/s/a/n): "
    read -r choice
    
    case "$choice" in
        o)
            cp "$source_file" "$dest_file"
            print_color "$GREEN" "   ✓ Overwritten"
            return 0
            ;;
        s)
            print_color "$YELLOW" "   → Skipped"
            return 1
            ;;
        a)
            OVERWRITE_ALL="y"
            cp "$source_file" "$dest_file"
            print_color "$GREEN" "   ✓ Overwritten (and will overwrite all)"
            return 0
            ;;
        n)
            SKIP_ALL="y"
            print_color "$YELLOW" "   → Skipped (and will skip all)"
            return 1
            ;;
        *)
            print_color "$RED" "   Invalid choice, skipping file"
            return 1
            ;;
    esac
}

# Copy a file with conflict handling
copy_with_check() {
    local source="$1"
    local dest="$2"
    local file_type="$3"
    
    if [ -f "$dest" ]; then
        handle_file_conflict "$source" "$dest" "$file_type"
    else
        cp "$source" "$dest"
    fi
}

# Copy framework files
copy_framework_files() {
    print_color "$YELLOW" "Copying framework files..."
    echo
    
    # Copy commands
    if [ -d "$SCRIPT_DIR/commands" ]; then
        for cmd in "$SCRIPT_DIR/commands/"*.md; do
            if [ -f "$cmd" ]; then
                dest="$TARGET_DIR/commands/$(basename "$cmd")"
                copy_with_check "$cmd" "$dest" "Command template"
            fi
        done
    fi
    
    # Copy hooks based on user selections
    if [ -d "$SCRIPT_DIR/hooks" ]; then
        # Always copy subagent context injector (core feature)
        if [ -f "$SCRIPT_DIR/hooks/subagent-context-injector.sh" ]; then
            copy_with_check "$SCRIPT_DIR/hooks/subagent-context-injector.sh" \
                          "$TARGET_DIR/hooks/subagent-context-injector.sh" \
                          "Hook script (core feature)"
        fi
        
        # Copy MCP security scanner if any MCP server is selected
        if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/mcp-security-scan.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/mcp-security-scan.sh" \
                              "$TARGET_DIR/hooks/mcp-security-scan.sh" \
                              "MCP security scanner hook"
            fi
        fi
        
        # Copy Gemini context injector if Gemini is selected
        if [ "$INSTALL_GEMINI" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/gemini-context-injector.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/gemini-context-injector.sh" \
                              "$TARGET_DIR/hooks/gemini-context-injector.sh" \
                              "Gemini context injector hook"
            fi
        fi
        
        # Copy notification hook and sounds if notifications are selected
        if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/notify.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/notify.sh" \
                              "$TARGET_DIR/hooks/notify.sh" \
                              "Notification hook"
            fi
            
            # Copy sounds with conflict handling
            if [ -d "$SCRIPT_DIR/hooks/sounds" ]; then
                for sound in "$SCRIPT_DIR/hooks/sounds/"*; do
                    if [ -f "$sound" ]; then
                        dest="$TARGET_DIR/hooks/sounds/$(basename "$sound")"
                        copy_with_check "$sound" "$dest" "Notification sound"
                    fi
                done
            fi
        fi
        
        # Copy config files with conflict handling
        if [ -d "$SCRIPT_DIR/hooks/config" ]; then
            for config in "$SCRIPT_DIR/hooks/config/"*; do
                if [ -f "$config" ]; then
                    dest="$TARGET_DIR/hooks/config/$(basename "$config")"
                    copy_with_check "$config" "$dest" "Configuration file"
                fi
            done
        fi
        
        # Copy README for reference
        if [ -f "$SCRIPT_DIR/hooks/README.md" ]; then
            copy_with_check "$SCRIPT_DIR/hooks/README.md" \
                          "$TARGET_DIR/hooks/README.md" \
                          "Hooks documentation"
        fi
        
        # Copy setup files
        if [ -d "$SCRIPT_DIR/hooks/setup" ]; then
            mkdir -p "$TARGET_DIR/hooks/setup"
            for setup_file in "$SCRIPT_DIR/hooks/setup/"*; do
                if [ -f "$setup_file" ]; then
                    dest="$TARGET_DIR/hooks/setup/$(basename "$setup_file")"
                    copy_with_check "$setup_file" "$dest" "Setup file"
                fi
            done
        fi
    fi
    
    # Copy documentation structure
    if [ -d "$SCRIPT_DIR/docs" ]; then
        # Copy ai-context files
        if [ -d "$SCRIPT_DIR/docs/ai-context" ]; then
            for doc in "$SCRIPT_DIR/docs/ai-context/"*.md; do
                if [ -f "$doc" ]; then
                    dest="$TARGET_DIR/docs/ai-context/$(basename "$doc")"
                    copy_with_check "$doc" "$dest" "AI context documentation"
                fi
            done
        fi
        
        # Copy example issues
        if [ -d "$SCRIPT_DIR/docs/open-issues" ]; then
            for issue in "$SCRIPT_DIR/docs/open-issues/"*.md; do
                if [ -f "$issue" ]; then
                    dest="$TARGET_DIR/docs/open-issues/$(basename "$issue")"
                    copy_with_check "$issue" "$dest" "Issue template"
                fi
            done
        fi
        
        # Copy spec templates
        if [ -d "$SCRIPT_DIR/docs/specs" ]; then
            for spec in "$SCRIPT_DIR/docs/specs/"*.md; do
                if [ -f "$spec" ]; then
                    dest="$TARGET_DIR/docs/specs/$(basename "$spec")"
                    copy_with_check "$spec" "$dest" "Specification template"
                fi
            done
        fi
        
        # Copy docs README
        if [ -f "$SCRIPT_DIR/docs/README.md" ]; then
            copy_with_check "$SCRIPT_DIR/docs/README.md" \
                          "$TARGET_DIR/docs/README.md" \
                          "Documentation guide"
        fi
    fi
    
    # Create CLAUDE.md from template if it doesn't exist
    if [ ! -f "$TARGET_DIR/CLAUDE.md" ] && [ -f "$SCRIPT_DIR/docs/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/docs/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        print_color "$GREEN" "✓ Created CLAUDE.md from template"
    else
        if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
            print_color "$YELLOW" "→ Preserved existing CLAUDE.md"
        fi
    fi
    
    # Create MCP-ASSISTANT-RULES.md from template if Gemini is selected
    if [ "$INSTALL_GEMINI" = "y" ]; then
        if [ ! -f "$TARGET_DIR/MCP-ASSISTANT-RULES.md" ] && [ -f "$SCRIPT_DIR/docs/MCP-ASSISTANT-RULES.md" ]; then
            cp "$SCRIPT_DIR/docs/MCP-ASSISTANT-RULES.md" "$TARGET_DIR/MCP-ASSISTANT-RULES.md"
            print_color "$GREEN" "✓ Created MCP-ASSISTANT-RULES.md from template"
        else
            if [ -f "$TARGET_DIR/MCP-ASSISTANT-RULES.md" ]; then
                print_color "$YELLOW" "→ Preserved existing MCP-ASSISTANT-RULES.md"
            fi
        fi
    else
        print_color "$YELLOW" "→ Skipped MCP-ASSISTANT-RULES.md (Gemini not selected)"
    fi
    
    print_color "$GREEN" "✓ Framework files copied"
}

# Set executable permissions
set_permissions() {
    print_color "$YELLOW" "Setting file permissions..."
    
    # Make only copied shell scripts executable
    if [ -d "$TARGET_DIR/hooks" ]; then
        for script in "$TARGET_DIR/hooks/"*.sh; do
            if [ -f "$script" ]; then
                chmod +x "$script"
            fi
        done
    fi
    
    print_color "$GREEN" "✓ Permissions set"
}

# Generate configuration file
generate_config() {
    print_color "$YELLOW" "Generating configuration..."
    
    local config_file="$TARGET_DIR/.claude/settings.local.json"
    
    # Start building the configuration
    cat > "$config_file" << EOF
{
  "environment": {
    "WORKSPACE": "$TARGET_DIR"
  },
  "experimentalTools": {
EOF

    # Add notification configuration if enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        cat >> "$config_file" << EOF
    "notify": {
      "commandAfterRun": "bash $TARGET_DIR/hooks/notify.sh",
      "commandAfterUserInput": "bash $TARGET_DIR/hooks/notify.sh input"
    }
EOF
    fi
    
    cat >> "$config_file" << EOF
  },
  "experimentalHooks": {
EOF

    # Add hooks configuration
    local hooks_added=false
    
    # Security scan hook (always enabled if MCP is used)
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        cat >> "$config_file" << EOF
    "preToolUse": "bash $TARGET_DIR/hooks/mcp-security-scan.sh",
EOF
        hooks_added=true
    fi
    
    # Gemini context injector
    if [ "$INSTALL_GEMINI" = "y" ]; then
        cat >> "$config_file" << EOF
    "preToolUse_gemini": "bash $TARGET_DIR/hooks/gemini-context-injector.sh",
EOF
        hooks_added=true
    fi
    
    # Sub-agent context injector
    cat >> "$config_file" << EOF
    "preToolUse_task": "bash $TARGET_DIR/hooks/subagent-context-injector.sh"
EOF
    
    cat >> "$config_file" << EOF
  }
}
EOF
    
    print_color "$GREEN" "✓ Configuration generated: $config_file"
}

# Display MCP server information
display_mcp_info() {
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        echo
        print_color "$BLUE" "=== MCP Server Setup (Required) ==="
        echo
        echo "To complete the setup, you need to install the MCP servers you selected:"
        echo
        
        if [ "$INSTALL_CONTEXT7" = "y" ]; then
            print_color "$YELLOW" "Context7 MCP Server:"
            echo "  Repository: https://github.com/upstash/context7"
            echo "  Documentation: See the Context7 README for setup instructions"
            echo
        fi
        
        if [ "$INSTALL_GEMINI" = "y" ]; then
            print_color "$YELLOW" "Gemini MCP Server:"
            echo "  Repository: https://github.com/peterkrueck/mcp-gemini-assistant"
            echo "  Documentation: See the MCP Gemini Assistant README for setup instructions"
            echo
        fi
        
        echo "After installing the MCP servers, add their configuration to:"
        print_color "$BLUE" "  $TARGET_DIR/.claude/settings.local.json"
        echo
        echo "Add a 'mcpServers' section with the appropriate server configurations."
    fi
}

# Show next steps
show_next_steps() {
    echo
    print_color "$GREEN" "=== Installation Complete! ==="
    echo
    print_color "$YELLOW" "Next Steps:"
    echo
    local step_num=1
    
    echo "${step_num}. Customize your project context:"
    echo "   - Edit: $TARGET_DIR/CLAUDE.md"
    echo "   - Update project structure in: $TARGET_DIR/docs/ai-context/project-structure.md"
    echo
    ((step_num++))
    
    if [ "$INSTALL_GEMINI" = "y" ]; then
        echo "${step_num}. Set your coding standards for Gemini:"
        echo "   - Edit: $TARGET_DIR/MCP-ASSISTANT-RULES.md"
        echo
        ((step_num++))
    fi
    
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        echo "${step_num}. Configure security patterns:"
        echo "   - Edit: $TARGET_DIR/hooks/config/sensitive-patterns.json"
        echo
        ((step_num++))
    fi
    
    echo "${step_num}. Test your installation:"
    echo "   - Run: claude"
    echo "   - Then: /full-context \"analyze my project structure\""
    echo
    ((step_num++))
    
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        echo "${step_num}. Test notifications:"
        echo "   - Run: bash $TARGET_DIR/hooks/notify.sh"
        echo
    fi
    
    print_color "$BLUE" "For documentation and examples, see:"
    echo "  - Commands: $TARGET_DIR/commands/README.md"
    echo "  - Hooks: $TARGET_DIR/hooks/README.md"
    echo "  - Docs: $TARGET_DIR/docs/README.md"
}

# Main execution
main() {
    print_header
    
    # Run checks
    check_claude_code
    check_required_tools
    
    # Get user input
    get_target_directory
    prompt_optional_components
    
    # Confirm installation
    echo
    print_color "$YELLOW" "Ready to install AI Development Framework to:"
    echo "  $TARGET_DIR"
    echo
    echo -n "Continue? (y/n): "
    read -r confirm
    
    if [ "$confirm" != "y" ]; then
        print_color "$RED" "Installation cancelled"
        exit 0
    fi
    
    # Perform installation
    create_directories
    copy_framework_files
    set_permissions
    generate_config
    
    # Show completion information
    display_mcp_info
    show_next_steps
}

# Run the script
main "$@"