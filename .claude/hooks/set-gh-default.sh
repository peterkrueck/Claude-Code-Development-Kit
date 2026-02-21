#!/bin/bash
# GitHub Default Repository Hook
# Ensures `gh` CLI targets this repository (not an upstream fork) for PR creation.
#
# In forked repos, `gh pr create` defaults to the upstream parent repository.
# This hook extracts owner/repo from the git origin remote and runs
# `gh repo set-default` so PRs target the correct repository.
#
# Intended to run as a SessionStart hook so every new session is configured
# automatically -- especially useful for Claude Code Web where .git/ state
# does not persist between sessions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/gh-default.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_event() {
    local event_type="$1"
    local details="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$timestamp\", \"event\": \"$event_type\", \"details\": \"$details\"}" >> "$LOG_FILE"
}

main() {
    # Skip if gh CLI is not available
    if ! command -v gh &>/dev/null; then
        log_event "skipped" "gh_cli_not_found"
        exit 0
    fi

    # Skip if already configured this session
    if [[ -f ".git/.gh-resolved" ]]; then
        log_event "skipped" "already_configured"
        exit 0
    fi

    # Extract origin remote URL
    local origin_url
    origin_url=$(git remote get-url origin 2>/dev/null) || {
        log_event "skipped" "no_origin_remote"
        exit 0
    }

    # Parse owner/repo from common URL formats:
    #   https://github.com/owner/repo.git
    #   git@github.com:owner/repo.git
    #   http://proxy@host/git/owner/repo
    local repo
    repo=$(echo "$origin_url" | sed -E 's/\.git$//' | sed -E 's#.*[:/]([^/]+/[^/]+)$#\1#')

    if [[ -z "$repo" || "$repo" == "$origin_url" ]]; then
        log_event "error" "could_not_parse_origin: $origin_url"
        exit 0
    fi

    # Set the default repository for gh CLI
    if gh repo set-default "$repo" 2>/dev/null; then
        log_event "configured" "default_repo_set_to: $repo"
    else
        log_event "error" "gh_repo_set_default_failed_for: $repo"
    fi

    exit 0
}

main
