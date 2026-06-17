#!/bin/bash
# track-file-touch.sh — Log files this session edits (PostToolUse on Write|Edit)
# Used by review-on-stop.sh to scope the git diff to only files THIS session
# changed, eliminating false positives from pre-session dirty state.
# Fast, non-blocking, always exits 0.

set -euo pipefail

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

# Nothing to record (missing jq, no path, or no session) — exit cleanly
[[ -z "$FILE_PATH" || "$SESSION_ID" == "unknown" ]] && exit 0

# Append to per-session manifest. Single-line writes are atomic; review-on-stop.sh
# deduplicates with sort -u, so duplicate appends are harmless.
echo "$FILE_PATH" >> "/tmp/claude-touched-${SESSION_ID}.files" 2>/dev/null || true
exit 0
