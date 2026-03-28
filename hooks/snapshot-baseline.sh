#!/bin/bash
# snapshot-baseline.sh — Capture git diff baseline at session start
# Runs on Notification events. Only snapshots once per session (first invocation).
# The stop hook uses this baseline to exclude pre-existing dirty files.
# Configuration: hooks/config/pipeline.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
BASELINE="/tmp/claude-baseline-${SESSION_ID}.numstat"

# Only snapshot once per session
[[ -f "$BASELINE" ]] && exit 0

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Read file patterns from config
CONFIG_FILE="$SCRIPT_DIR/config/pipeline.json"
if [[ -f "$CONFIG_FILE" ]]; then
    mapfile -t FILE_PATTERNS < <(jq -r '(.file_patterns // ["*.py","*.ts","*.js","*.swift","*.go","*.rs"]) | .[]' "$CONFIG_FILE" 2>/dev/null)
else
    FILE_PATTERNS=("*.py" "*.ts" "*.js" "*.swift" "*.go" "*.rs")
fi

git diff --numstat HEAD -- "${FILE_PATTERNS[@]}" 2>/dev/null > "$BASELINE"
exit 0
