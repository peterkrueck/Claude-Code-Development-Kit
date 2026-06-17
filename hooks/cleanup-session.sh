#!/bin/bash
# cleanup-session.sh — Remove per-session temp files on SessionEnd
# Belt-and-suspenders: /tmp is also cleared on reboot for orphaned files.

set -euo pipefail

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

[[ "$SESSION_ID" == "unknown" ]] && exit 0

rm -f "/tmp/claude-baseline-${SESSION_ID}.numstat" \
      "/tmp/claude-stop-${SESSION_ID}.state" \
      "/tmp/claude-touched-${SESSION_ID}.files"
exit 0
