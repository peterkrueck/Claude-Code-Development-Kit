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
DIM='\033[2m'
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
INSTALL_REVIEW_ON_STOP="n"
INSTALL_NOTIFICATIONS="n"

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

# ── Tutorial ─────────────────────────────────────────────────────────────

# Terminology + workflow overview shown before feature selection
# so users understand what they're choosing.
show_workflow_overview() {
    echo
    print_color "$BLUE" "─── How It Works ───"
    echo
    print_color "$DIM" "  Terminology:"
    echo "    Skills   — things Claude does (auto or via /slash-command)"
    echo "    Hooks    — background automation (security, review nudges, sounds)"
    echo "    Commands — you type /prime to load project context"
    echo
    print_color "$DIM" "  A typical session with all features enabled:"
    echo
    print_color "$YELLOW" "  1. Start"
    echo "     \$ cd your-project && claude"
    echo
    print_color "$YELLOW" "  2. Load context"
    print_color "$GREEN" "     > /prime"
    print_color "$CYAN" "     \"I see a Node.js API with Postgres. Auth is done,"
    print_color "$CYAN" "      payments module is next. What are we working on?\""
    echo
    print_color "$YELLOW" "  3. Describe your task — Claude writes the code"
    print_color "$GREEN" "     > Add a /users/me endpoint with auth"
    echo "     ✓ Creates files, runs tests, verifies."
    echo
    print_color "$YELLOW" "  4. Independent code review"
    print_color "$GREEN" "     > /review-work"
    echo "     Parallel sub-agents catch bugs, security issues, rule violations."
    print_color "$DIM" "                                                  (review skills)"
    echo
    print_color "$YELLOW" "  5. Create visual assets"
    print_color "$GREEN" "     > Generate an app icon, crop to 1024x1024, remove bg"
    echo "     AI generation → precision editing → local background removal."
    print_color "$DIM" "                                                  (visual skills)"
    echo
    print_color "$YELLOW" "  6. Keep docs in sync"
    print_color "$GREEN" "     > /update-docs"
    echo "     Only updates what actually changed."
    echo
    print_color "$YELLOW" "  7. Finish — review-on-stop nudges you"
    echo "     stop → advisory → stop → reminder → stop → exit"
    echo "     Gentle nudge to review. Never traps you."
    print_color "$DIM" "                                                  (review-on-stop)"
    echo
    print_color "$DIM" "  Always on: security scanner blocks secrets from leaking."
    print_color "$DIM" "  Notifications: sound alerts when Claude finishes or needs input."
    echo
}

safe_read_setup_mode() {
    local var_name="$1"
    local prompt="$2"
    local user_input sanitized_input valid_input=false
    while [ "$valid_input" = false ]; do
        if ! safe_read user_input "$prompt"; then return 1; fi
        sanitized_input="$(echo "${user_input//$'\r'/}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
        case "$sanitized_input" in
            f|c|m) valid_input=true; printf -v "$var_name" '%s' "$sanitized_input" ;;
            *) print_color "$YELLOW" "Please enter 'f', 'c', or 'm'." ;;
        esac
    done
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

    # ── Workflow overview (before feature selection) ────────────────────
    show_workflow_overview

    # ── Feature selection ────────────────────────────────────────────────
    print_color "$BLUE" "─── Feature Selection ───"
    echo
    print_color "$GREEN" "  Core (always installed):"
    echo "    - CLAUDE.md — your project's AI instruction set"
    echo "    - /prime command — loads core documentation into context"
    echo "    - /update-docs skill — keeps documentation in sync with code"
    echo "    - Security scanner — blocks secrets from leaking to MCP/plugins"
    echo "    - Deny list — prevents destructive git/rm commands"
    echo "    - Documentation scaffolding (spec, structure, progress, deployment)"
    echo "    - Asset directories (assets/)"
    echo
    print_color "$CYAN" "  How do you want to set up optional features?"
    echo
    echo "    [f] Full       — all skills, hooks, and templates (recommended)"
    echo "    [c] Customize  — choose each feature individually"
    echo "    [m] Minimal    — core only, add features later"
    echo
    safe_read_setup_mode setup_mode "    Your choice (f/c/m): "
    echo

    case "$setup_mode" in
        f)
            INSTALL_REVIEW_SKILLS="y"
            INSTALL_VISUAL_SKILLS="y"
            INSTALL_DEPLOY_TEMPLATE="y"
            INSTALL_GEMINI="y"
            INSTALL_REVIEW_ON_STOP="y"
            INSTALL_NOTIFICATIONS="y"
            print_color "$GREEN" "  Full install:"
            echo "    ✓ Review skills (/review-work, /second-opinion)"
            echo "    ✓ Visual skills (/image-gen, /image-edit, /bg-remove)"
            echo "    ✓ Deploy skill template"
            echo "    ✓ GEMINI.md template"
            echo "    ✓ Review-on-stop hook"
            echo "    ✓ Audio notifications"
            echo
            print_color "$DIM" "  Some skills need additional setup — see post-install notes."
            ;;
        m)
            print_color "$GREEN" "  Minimal: core only."
            print_color "$DIM" "  Re-run setup.sh anytime to add features."
            ;;
        c)
            # Review Skills
            print_color "$CYAN" "  Review Skills"
            echo "    Independent code review using parallel Claude sub-agents, plus"
            echo "    architecture consultation via Gemini CLI for genuinely independent"
            echo "    second opinions."
            echo
            echo "    Includes: /review-work (Claude sub-agents), /second-opinion (Gemini)"
            print_color "$DIM" "    /second-opinion requires: Gemini CLI (https://github.com/google-gemini/gemini-cli)"
            safe_read_yn INSTALL_REVIEW_SKILLS "    Install review skills? (y/n): "
            echo

            # Visual Skills
            print_color "$CYAN" "  Visual Skills"
            echo "    For any project that needs visual assets — app icons, UI artwork,"
            echo "    social media graphics, marketing materials, or website imagery."
            echo "    Generate images with AI (reference photos for consistency),"
            echo "    crop and resize precisely, and remove backgrounds locally."
            echo
            echo "    Includes: /image-gen, /image-edit, /bg-remove"
            print_color "$DIM" "    Requires: Python 3 with Pillow/numpy"
            print_color "$DIM" "    /image-gen also requires: GEMINI_API_KEY env variable (~\$0.10/image)"
            print_color "$DIM" "    /bg-remove also requires: rembg (pip install \"rembg[cpu,cli]\")"
            safe_read_yn INSTALL_VISUAL_SKILLS "    Install visual skills? (y/n): "
            echo

            # Deploy Template
            print_color "$CYAN" "  Deploy Skill Template"
            echo "    A customizable deployment pipeline you fill in with your own"
            echo "    test, deploy, and health check commands. Follows the pattern:"
            echo "    detect changes -> run tests -> deploy -> verify -> report."
            safe_read_yn INSTALL_DEPLOY_TEMPLATE "    Install deploy template? (y/n): "
            echo

            # Gemini Integration
            print_color "$CYAN" "  Gemini Integration"
            echo "    Creates GEMINI.md — an instruction file that Gemini CLI reads"
            echo "    automatically, giving it full context about your project when"
            echo "    invoked as a second-opinion consultant."
            if [ "$INSTALL_REVIEW_SKILLS" = "y" ]; then
                print_color "$GREEN" "    Recommended: you selected review skills which use Gemini."
            fi
            safe_read_yn INSTALL_GEMINI "    Install GEMINI.md template? (y/n): "
            echo

            # Review-on-Stop
            print_color "$CYAN" "  Review-on-Stop Hook"
            echo "    Nudges you to review before finishing. When you have 10+"
            echo "    lines of new code, the first stop shows an advisory with"
            echo "    changed files and suggests review/test/docs. Stop again"
            echo "    to get a reminder, stop a third time to skip entirely."
            echo "    Never traps you — three stops always gets you out."
            safe_read_yn INSTALL_REVIEW_ON_STOP "    Install review-on-stop? (y/n): "
            echo

            # Notifications
            print_color "$CYAN" "  Audio Notifications"
            echo "    Plays a sound when Claude finishes a task or needs your input."
            echo "    Useful when working in another window. Supports macOS and Linux."
            safe_read_yn INSTALL_NOTIFICATIONS "    Install notifications? (y/n): "
            ;;
    esac

    # Confirm
    echo
    print_color "$YELLOW" "Ready to install to: $TARGET_DIR"
    echo
    print_color "$GREEN" "  Will install:"
    echo "    - Core (CLAUDE.md, /prime, /merge, /update-docs, security, docs, assets)"
    [ "$INSTALL_REVIEW_SKILLS" = "y" ] && echo "    - Review skills (/review-work, /second-opinion)"
    [ "$INSTALL_VISUAL_SKILLS" = "y" ] && echo "    - Visual skills (/image-gen, /image-edit, /bg-remove)"
    [ "$INSTALL_DEPLOY_TEMPLATE" = "y" ] && echo "    - Deploy skill template"
    [ "$INSTALL_GEMINI" = "y" ] && echo "    - GEMINI.md template"
    [ "$INSTALL_REVIEW_ON_STOP" = "y" ] && echo "    - Review-on-stop hook"
    [ "$INSTALL_NOTIFICATIONS" = "y" ] && echo "    - Audio notifications"
    echo
    safe_read_yn confirm "  Continue? (y/n): "
    [ "$confirm" != "y" ] && { print_color "$RED" "Cancelled."; exit 0; }

    # ── Create directories ───────────────────────────────────────────────
    echo
    print_color "$YELLOW" "Creating directories..."
    mkdir -p "$TARGET_DIR/.claude/commands"
    mkdir -p "$TARGET_DIR/.claude/hooks/config"
    mkdir -p "$TARGET_DIR/.claude/skills"
    mkdir -p "$TARGET_DIR/docs/ai-context"
    mkdir -p "$TARGET_DIR/assets"
    for d in legal business design-brand open-issues; do
        mkdir -p "$TARGET_DIR/docs/$d"
        [ ! -f "$TARGET_DIR/docs/$d/.gitkeep" ] && touch "$TARGET_DIR/docs/$d/.gitkeep"
    done

    if [ "$INSTALL_NOTIFICATIONS" = "y" ] || [ "$INSTALL_REVIEW_ON_STOP" = "y" ]; then
        mkdir -p "$TARGET_DIR/.claude/hooks/sounds"
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

    # Commands
    copy_file "$SCRIPT_DIR/commands/prime.md" "$TARGET_DIR/.claude/commands/prime.md" "Command"
    copy_file "$SCRIPT_DIR/commands/merge.md" "$TARGET_DIR/.claude/commands/merge.md" "Command"

    # /update-docs skill (core — always installed)
    mkdir -p "$TARGET_DIR/.claude/skills/update-docs"
    copy_file "$SCRIPT_DIR/skills/update-docs/SKILL.md" "$TARGET_DIR/.claude/skills/update-docs/SKILL.md" "Skill"

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
        for skill in review-work second-opinion; do
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

    # Review-on-stop hook
    if [ "$INSTALL_REVIEW_ON_STOP" = "y" ]; then
        copy_file "$SCRIPT_DIR/hooks/review-on-stop.sh" "$TARGET_DIR/.claude/hooks/review-on-stop.sh" "Hook"
        copy_file "$SCRIPT_DIR/hooks/snapshot-baseline.sh" "$TARGET_DIR/.claude/hooks/snapshot-baseline.sh" "Hook"
        copy_file "$SCRIPT_DIR/hooks/config/pipeline.json" "$TARGET_DIR/.claude/hooks/config/pipeline.json" "Config"
    fi

    # Notification sounds
    if [ "$INSTALL_NOTIFICATIONS" = "y" ] || [ "$INSTALL_REVIEW_ON_STOP" = "y" ]; then
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
    if [ "$INSTALL_REVIEW_ON_STOP" = "y" ]; then
        hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"Stop": [{
            "hooks": [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/review-on-stop.sh"), "timeout": 10000}]
        }]}')
    fi

    # Notification hook
    local notification_hooks='[]'
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        notification_hooks=$(echo "$notification_hooks" | jq --arg dir "$TARGET_DIR" \
            '. + [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/notify.sh input")}]')
    fi
    if [ "$(echo "$notification_hooks" | jq 'length')" -gt 0 ]; then
        hooks_json=$(echo "$hooks_json" | jq --argjson nh "$notification_hooks" '. + {"Notification": [{"hooks": $nh}]}')
    fi

    # SessionStart: baseline snapshot (captures git state before any work)
    if [ "$INSTALL_REVIEW_ON_STOP" = "y" ]; then
        hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"SessionStart": [{
            "hooks": [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/snapshot-baseline.sh")}]
        }]}')
    fi

    # Add stop notification if notifications enabled but review-on-stop is NOT (it handles its own completion sound)
    if [ "$INSTALL_NOTIFICATIONS" = "y" ] && [ "$INSTALL_REVIEW_ON_STOP" != "y" ]; then
        hooks_json=$(echo "$hooks_json" | jq --arg dir "$TARGET_DIR" '. + {"Stop": [{
            "hooks": [{"type": "command", "command": ("bash " + $dir + "/.claude/hooks/notify.sh complete")}]
        }]}')
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
    echo
    print_color "$CYAN" "  Recommended plugin:"
    echo "    claude plugins add context7"
    echo "    Gives Claude access to up-to-date library documentation."
    echo "    Highly recommended for any project using external libraries."
    echo

    # Dynamic setup instructions based on selections
    local needs_gemini_cli=false
    local needs_gemini_key=false
    local needs_rembg=false

    [ "$INSTALL_VISUAL_SKILLS" = "y" ] && needs_gemini_key=true && needs_rembg=true
    # /second-opinion and GEMINI.md need Gemini CLI
    [ "$INSTALL_REVIEW_SKILLS" = "y" ] && needs_gemini_cli=true
    [ "$INSTALL_GEMINI" = "y" ] && needs_gemini_cli=true

    if [ "$needs_gemini_cli" = true ] && ! command -v gemini &>/dev/null; then
        print_color "$YELLOW" "  Gemini CLI required (/second-opinion + GEMINI.md):"
        echo "    See: https://github.com/google-gemini/gemini-cli"
        echo
    fi
    if [ "$needs_gemini_key" = true ]; then
        print_color "$YELLOW" "  Gemini API key required (/image-gen):"
        echo "    export GEMINI_API_KEY=your-key"
        echo "    Get one at: https://aistudio.google.com/apikey"
        echo
    fi
    if [ "$needs_rembg" = true ]; then
        print_color "$YELLOW" "  rembg required (/bg-remove):"
        echo "    pip install \"rembg[cpu,cli]\""
        echo
    fi
    echo "  Test your setup:"
    echo "    cd \"$TARGET_DIR\" && claude"
    echo "    Then: /prime"
    echo
    print_color "$DIM" "  To uninstall: remove .claude/, docs/ai-context/, assets/,"
    print_color "$DIM" "  CLAUDE.md, and GEMINI.md from your project."
    echo
    print_color "$DIM" "  To add features later: re-run setup.sh (existing files"
    print_color "$DIM" "  are preserved unless you choose to overwrite)."
}

main "$@"
