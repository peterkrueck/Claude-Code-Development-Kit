#!/bin/bash
# snapshot-baseline.sh — Capture git diff baseline at session start
# Runs on Notification events. Only snapshots once per session (first invocation).
# The stop hook uses this baseline to exclude pre-existing dirty files.
# Configuration: hooks/config/pipeline.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
[[ -z "$SESSION_ID" ]] && exit 0  # Can't snapshot without session ID
BASELINE="/tmp/claude-baseline-${SESSION_ID}.numstat"

# Only snapshot once per session
[[ -f "$BASELINE" ]] && exit 0

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Read file patterns from config (bash 3.2 compatible — no mapfile)
CONFIG_FILE="$SCRIPT_DIR/config/pipeline.json"
FILE_PATTERNS=()
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r _pat; do
        [[ -n "$_pat" ]] && FILE_PATTERNS+=("$_pat")
    done < <(jq -r '(.file_patterns // ["*.py","*.ts","*.js","*.swift","*.go","*.rs"]) | .[]' "$CONFIG_FILE" 2>/dev/null)
else
    FILE_PATTERNS=("*.py" "*.ts" "*.js" "*.swift" "*.go" "*.rs")
fi

git diff --numstat HEAD -- "${FILE_PATTERNS[@]}" 2>/dev/null > "$BASELINE"
exit 0
