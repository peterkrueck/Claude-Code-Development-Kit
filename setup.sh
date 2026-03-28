#!/usr/bin/env bash

# Claude Code Development Kit v3.0.0 — Setup Script
#
# Installs skills, hooks, templates, and settings into a target project.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# State
TARGET_DIR=""
OVERWRITE_ALL="n"
SKIP_ALL="n"

# Feature flags
INSTALL_REVIEW_SKILLS="n"
INSTALL_VISUAL_SKILLS="n"
INSTALL_DEPLOY_TEMPLATE="n"
INSTALL_GEMINI="n"
INSTALL_STOP_PIPELINE="n"
INSTALL_NOTIFICATIONS="n"
INSTALL_CONTEXT7="n"
INSTALL_SUPABASE="n"
INSTALL_ASSETS="n"

print_color() {
    local color=$1; shift
    echo -e "${color}$@${NC}"
}

# Safe read that works in piped contexts (curl | bash)
safe_read() {
    local var_name="$1"
    local prompt="$2"
    local input_source
    if [ -t 0 ]; then input_source="/dev/stdin"; else input_source="/dev/tty"; fi
    read -r -p "$prompt" temp_input < "$input_source"
    printf -v "$var_name" '%s' "$temp_input"
}

safe_read_yn() {
    local var_name="$1"
    local prompt="$2"
    local user_input sanitized_input valid_input=false
    while [ "$valid_input" = false ]; do
        if ! safe_read user_input "$prompt"; then return 1; fi
        sanitized_input="$(echo "${user_input//$'\r'/}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
        case "$sanitized_input" in
            y|n) valid_input=true; printf -v "$var_name" '%s' "$sanitized_input" ;;
            *) print_color "$YELLOW" "Please enter 'y' or 'n'." ;;
        esac
    done
}

safe_read_conflict() {
    local var_name="$1"
    local user_input sanitized_input valid_input=false
    while [ "$valid_input" = false ]; do
        if ! safe_read user_input "   Your choice: "; then return 1; fi
        sanitized_input="$(echo "${user_input//$'\r'/}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
        case "$sanitized_input" in
            o|s|a|n) valid_input=true; printf -v "$var_name" '%s' "$sanitized_input" ;;
            *) print_color "$YELLOW" "   Enter o, s, a, or n." ;;
        esac
    done
}

handle_file_conflict() {
    local source_file="$1" dest_file="$2" file_type="$3"
    if [ "$OVERWRITE_ALL" = "y" ]; then cp "$source_file" "$dest_file"; return 0; fi
    if [ "$SKIP_ALL" = "y" ]; then return 1; fi
    print_color "$YELLOW" "  File exists: $(basename "$dest_file")"
    echo "   [o] Overwrite  [s] Skip  [a] Always overwrite  [n] Never overwrite"
    if ! safe_read_conflict choice; then return 1; fi
    case "$choice" in
        o) cp "$source_file" "$dest_file" ;;
        s) return 1 ;;
        a) OVERWRITE_ALL="y"; cp "$source_file" "$dest_file" ;;
        n) SKIP_ALL="y"; return 1 ;;
    esac
}

copy_file() {
    local source="$1" dest="$2" file_type="${3:-File}"
    if [ -f "$dest" ]; then
        handle_file_conflict "$source" "$dest" "$file_type"
    else
        cp "$source" "$dest"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────

main() {
    echo
    print_color "$BLUE" "==========================================="
    print_color "$BLUE" "  Claude Code Development Kit v3.0.0"
    print_color "$BLUE" "==========================================="
    echo

    # Prerequisites
    print_color "$YELLOW" "Checking prerequisites..."
    if ! command -v claude &>/dev/null; then
        print_color "$RED" "Claude Code is not installed. Install: https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    fi
    if ! command -v jq &>/dev/null; then
        print_color "$RED" "jq is required. Install: brew install jq (macOS) or apt install jq (Linux)"
        exit 1
    fi
    print_color "$GREEN" "  Prerequisites OK"

    # Target directory
    echo
    print_color "$YELLOW" "Target project directory?"
    if ! safe_read input_dir "  Path (or . for current): "; then exit 1; fi
    if [ -z "$input_dir" ]; then
        print_color "$RED" "No path entered."; exit 1
    fi
    if [ "$input_dir" = "." ]; then
        TARGET_DIR="${INSTALLER_ORIGINAL_PWD:-$(pwd)}"
    else
        TARGET_DIR="$(cd "$input_dir" 2>/dev/null && pwd)" || { print_color "$RED" "Directory not found: $input_dir"; exit 1; }
    fi
    [ "$TARGET_DIR" = "$SCRIPT_DIR" ] && { print_color "$RED" "Cannot install into source directory"; exit 1; }
    print_color "$GREEN" "  Target: $TARGET_DIR"

    # ── Feature selection ────────────────────────────────────────────────
    echo
    print_color "$BLUE" "─── Feature Selection ───"
    echo
    print_color "$GREEN" "  Core (always installed):"
    echo "    CLAUDE.md template, /prime command, security scanner, deny list"
    echo "    Documentation scaffolding (spec, structure, progress, deployment)"
    echo

    print_color "$CYAN" "  Review Skills (Gemini CLI + Claude fallback)"
    echo "    /review-work, /second-opinion, /update-docs"
    safe_read_yn INSTALL_REVIEW_SKILLS "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Visual Skills (Python/Pillow/rembg)"
    echo "    /image-gen, /image-edit, /bg-remove"
    safe_read_yn INSTALL_VISUAL_SKILLS "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Deploy Skill Template"
    echo "    Customizable test-gated deployment pipeline"
    safe_read_yn INSTALL_DEPLOY_TEMPLATE "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Gemini Integration"
    echo "    GEMINI.md template for second-opinion consulting"
    safe_read_yn INSTALL_GEMINI "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Stop Pipeline Hook"
    echo "    Gates stopping on: code review -> tests -> doc updates"
    safe_read_yn INSTALL_STOP_PIPELINE "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Audio Notifications"
    echo "    Sounds when tasks complete or input is needed"
    safe_read_yn INSTALL_NOTIFICATIONS "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Asset Directories"
    echo "    Scaffolding: assets/{app-icon,character,logo,social,web}"
    safe_read_yn INSTALL_ASSETS "    Install? (y/n): "
    echo

    print_color "$CYAN" "  Plugins (permissions only — install separately)"
    echo "    Context7: claude plugins add context7"
    safe_read_yn INSTALL_CONTEXT7 "    Add Context7 permissions? (y/n): "
    echo "    Supabase: claude plugins add supabase"
    safe_read_yn INSTALL_SUPABASE "    Add Supabase permissions? (y/n): "

    # Confirm
    echo
    print_color "$YELLOW" "Ready to install to: $TARGET_DIR"
    safe_read_yn confirm "  Continue? (y/n): "
    [ "$confirm" != "y" ] && { print_color "$RED" "Cancelled."; exit 0; }

    # ── Create directories ───────────────────────────────────────────────
    echo
    print_color "$YELLOW" "Creating directories..."
    mkdir -p "$TARGET_DIR/.claude/commands"
    mkdir -p "$TARGET_DIR/.claude/hooks/config"
    mkdir -p "$TARGET_DIR/.claude/skills"
    mkdir -p "$TARGET_DIR/docs/ai-context"
    mkdir -p "$TARGET_DIR/docs/legal"
    mkdir -p "$TARGET_DIR/docs/business"
    mkdir -p "$TARGET_DIR/docs/design-brand"
    mkdir -p "$TARGET_DIR/docs/open-issues"

    if [ "$INSTALL_NOTIFICATIONS" = "y" ] || [ "$INSTALL_STOP_PIPELINE" = "y" ]; then
        mkdir -p "$TARGET_DIR/.claude/hooks/sounds"
    fi

    if [ "$INSTALL_ASSETS" = "y" ]; then
        mkdir -p "$TARGET_DIR/assets"/{app-icon,character,logo,social,web}
    fi

    # ── Copy core files ──────────────────────────────────────────────────
    print_color "$YELLOW" "Copying files..."

    # CLAUDE.md template
    if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        print_color "$GREEN" "  Created CLAUDE.md"
    else
        print_color "$YELLOW" "  Preserved existing CLAUDE.md"
    fi

    # /prime command
    copy_file "$SCRIPT_DIR/commands/prime.md" "$TARGET_DIR/.claude/commands/prime.md" "Command"

    # Security scanner
    copy_file "$SCRIPT_DIR/hooks/security-scan.sh" "$TARGET_DIR/.claude/hooks/security-scan.sh" "Hook"
    copy_file "$SCRIPT_DIR/hooks/config/sensitive-patterns.json" "$TARGET_DIR/.claude/hooks/config/sensitive-patterns.json" "Config"

    # Documentation templates
    for doc in spec.md project-structure.md progress.md deployment-infrastructure.md; do
        copy_file "$SCRIPT_DIR/templates/docs/ai-context/$doc" "$TARGET_DIR/docs/ai-context/$doc" "Documentation"
    done

    # ── Copy optional files ──────────────────────────────────────────────

    # Review skills
    if [ "$INSTALL_REVIEW_SKILLS" = "y" ]; then
        for skill in review-work second-opinion update-docs; do
            mkdir -p "$TARGET_DIR/.claude/skills/$skill"
            copy_file "$SCRIPT_DIR/skills/$skill/SKILL.md" "$TARGET_DIR/.claude/skills/$skill/SKILL.md" "Skill"
        done
    fi

    # Visual skills
    if [ "$INSTALL_VISUAL_SKILLS" = "y" ]; then
        # image-gen
        mkdir -p "$TARGET_DIR/.claude/skills/image-gen/scripts"
        copy_file "$SCRIPT_DIR/skills/image-gen/SKILL.md" "$TARGET_DIR/.claude/skills/image-gen/SKILL.md" "Skill"
        copy_file "$SCRIPT_DIR/skills/image-gen/scripts/generate.ts" "$TARGET_DIR/.claude/skills/image-gen/scripts/generate.ts" "Script"

        # image-edit
        mkdir -p "$TARGET_DIR/.claude/skills/image-edit/scripts"
        copy_file "$SCRIPT_DIR/skills/image-edit/SKILL.md" "$TARGET_DIR/.claude/skills/image-edit/SKILL.md" "Skill"
        copy_file "$SCRIPT_DIR/skills/image-edit/scripts/analyze_bounds.py" "$TARGET_DIR/.claude/skills/image-edit/scripts/analyze_bounds.py" "Script"
        copy_file "$SCRIPT_DIR/skills/image-edit/scripts/crop_image.py" "$TARGET_DIR/.claude/skills/image-edit/scripts/crop_image.py" "Script"

        # bg-remove
        mkdir -p "$TARGET_DIR/.claude/skills/bg-remove"
        copy_file "$SCRIPT_DIR/skills/bg-remove/SKILL.md" "$TARGET_DIR/.claude/skills/bg-remove/SKILL.md" "Skill"
    fi

    # Deploy template
    if [ "$INSTALL_DEPLOY_TEMPLATE" = "y" ]; then
        mkdir -p "$TARGET_DIR/.claude/skills/deploy"
        copy_file "$SCRIPT_DIR/skills/deploy/SKILL.md" "$TARGET_DIR/.claude/skills/deploy/SKILL.md" "Skill"
    fi

    # Gemini integration
    if [ "$INSTALL_GEMINI" = "y" ]; then
        if [ ! -f "$TARGET_DIR/GEMINI.md" ]; then
            cp "$SCRIPT_DIR/templates/GEMINI.md" "$TARGET_DIR/GEMINI.md"
            print_color "$GREEN" "  Created GEMINI.md"
        else
            print_color "$YELLOW" "  Preserved existing GEMINI.md"
        fi
    fi

    # Stop pipeline hook
    if [ "$INSTALL_STOP_PIPELINE" = "y" ]; then
        copy_file "$SCRIPT_DIR/hooks/stop-pipeline.sh" "$TARGET_DIR/.claude/hooks/stop-pipeline.sh" "Hook"
        copy_file "$SCRIPT_DIR/hooks/config/pipeline.json" "$TARGET_DIR/.claude/hooks/config/pipeline.json" "Config"
    fi

    # Notification sounds
    if [ "$INSTALL_NOTIFICATIONS" = "y" ] || [ "$INSTALL_STOP_PIPELINE" = "y" ]; then
        copy_file "$SCRIPT_DIR/hooks/notify.sh" "$TARGET_DIR/.claude/hooks/notify.sh" "Hook"
        for sound in "$SCRIPT_DIR/hooks/sounds/"*; do
            [ -f "$sound" ] && copy_file "$sound" "$TARGET_DIR/.claude/hooks/sounds/$(basename "$sound")" "Sound"
        done
    fi

    # ── Set permissions ──────────────────────────────────────────────────
    for script in "$TARGET_DIR/.claude/hooks/"*.sh; do
        [ -f "$script" ] && chmod +x "$script"
    done

    # ── Generate settings.local.json ─────────────────────────────────────
    print_color "$YELLOW" "Generating settings..."

    local config_file="$TARGET_DIR/.claude/settings.local.json"

    # Merge permission modules
    local allow_entries deny_entries
    allow_entries=$(jq -r '.allow[]' "$SCRIPT_DIR/settings/permissions/core.json")
    deny_entries=$(jq -r '.deny[]' "$SCRIPT_DIR/settings/permissions/core.json")

    if [ "$INSTALL_REVIEW_SKILLS" = "y" ]; then
        allow_entries="$allow_entries"$'\n'$(jq -r '.allow[]' "$SCRIPT_DIR/settings/permissions/skills-review.json")
    fi

    if [ "$INSTALL_VISUAL_SKILLS" = "y" ]; then
        allow_entries="$allow_entries"$'\n'$(jq -r '.allow[]' "$SCRIPT_DIR/settings/permissions/skills-visual.json")
    fi

    if [ "$INSTALL_CONTEXT7" = "y" ]; then
        allow_entries="$allow_entries"$'\n'$(jq -r '.allow[]' "$SCRIPT_DIR/settings/permissions/plugin-context7.json")
    fi

    if [ "$INSTALL_SUPABASE" = "y" ]; then
        allow_entries="$allow_entries"$'\n'$(jq -r '.allow[]' "$SCRIPT_DIR/settings/permissions/plugin-supabase.json")
    fi

    # Build allow and deny JSON arrays (filter empty lines)
    local allow_json deny_json
    allow_json=$(echo "$allow_entries" | grep -v '^$' | sort -u | jq -R . | jq -s .)
    deny_json=$(echo "$deny_entries" | grep -v '^$' | sort -u | jq -R . | jq -s .)

    # Build hooks JSON using --arg for safe path interpolation
    local hooks_json="{}"

    # PreToolUse: security scanner
    hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"PreToolUse": [{
        "matcher": "mcp__",
        "hooks": [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/security-scan.sh")}]
    }]}')

    # Stop hook
    if [ "$INSTALL_STOP_PIPELINE" = "y" ]; then
        hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"Stop": [{
            "hooks": [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/stop-pipeline.sh"), "timeout": 10000}]
        }]}')
    fi

    # Notification hook
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"Notification": [{
            "hooks": [{"type": "command", "command": ($dir + "/.claude/hooks/notify.sh input")}]
        }]}')
        # Add stop notification if stop pipeline is NOT installed (pipeline handles its own completion sound)
        if [ "$INSTALL_STOP_PIPELINE" != "y" ]; then
            hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"Stop": [{
                "hooks": [{"type": "command", "command": ($dir + "/.claude/hooks/notify.sh complete")}]
            }]}')
        fi
    fi

    # Compose final settings
    jq -n \
        --argjson allow "$allow_json" \
        --argjson deny "$deny_json" \
        --argjson hooks "$hooks_json" \
        '{
            permissions: {
                allow: $allow,
                deny: $deny,
                ask: []
            },
            hooks: $hooks
        }' > "$config_file"

    print_color "$GREEN" "  Generated: $config_file"

    # ── Summary ──────────────────────────────────────────────────────────
    echo
    print_color "$GREEN" "==========================================="
    print_color "$GREEN" "  Installation Complete!"
    print_color "$GREEN" "==========================================="
    echo
    print_color "$YELLOW" "Next steps:"
    echo
    echo "  1. Customize CLAUDE.md with your project rules"
    echo "  2. Fill in docs/ai-context/ templates"
    if [ "$INSTALL_GEMINI" = "y" ]; then
        echo "  3. Customize GEMINI.md with your project details"
    fi
    if [ "$INSTALL_STOP_PIPELINE" = "y" ]; then
        echo "  Edit .claude/hooks/config/pipeline.json for test commands"
    fi
    echo
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_SUPABASE" = "y" ]; then
        print_color "$CYAN" "  Install plugins:"
        [ "$INSTALL_CONTEXT7" = "y" ] && echo "    claude plugins add context7"
        [ "$INSTALL_SUPABASE" = "y" ] && echo "    claude plugins add supabase"
        echo
    fi
    if [ "$INSTALL_REVIEW_SKILLS" = "y" ] && ! command -v gemini &>/dev/null; then
        print_color "$YELLOW" "  Review skills require Gemini CLI:"
        echo "    See: https://github.com/google-gemini/gemini-cli"
        echo
    fi
    echo "  Test your setup:"
    echo "    cd \"$TARGET_DIR\" && claude"
    echo "    Then: /prime"
}

main "$@"
