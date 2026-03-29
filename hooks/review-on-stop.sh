#!/bin/bash
# review-on-stop.sh — Smart stop hook with session awareness
# Advisory model: suggests review/test/docs but never traps you.
# Three-phase stop: full advisory → quick reminder → allow.
# Configuration: hooks/config/pipeline.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
[[ -z "$SESSION_ID" ]] && exit 0  # Can't track phases without session ID
STATE_FILE="/tmp/claude-stop-${SESSION_ID}.state"
BASELINE="/tmp/claude-baseline-${SESSION_ID}.numstat"
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Load configuration
CONFIG_FILE="$SCRIPT_DIR/config/pipeline.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0  # No config = no pipeline
fi

ENABLED=$(jq -r '.enabled // true' "$CONFIG_FILE")
[[ "$ENABLED" != "true" ]] && exit 0

MIN_LINES=$(jq -r '.min_lines_changed // 10' "$CONFIG_FILE")

# Read file patterns from config (bash 3.2 compatible — no mapfile)
FILE_PATTERNS=()
while IFS= read -r _pat; do
    [[ -n "$_pat" ]] && FILE_PATTERNS+=("$_pat")
done < <(jq -r '(.file_patterns // ["*.py","*.ts","*.js","*.swift","*.go","*.rs"]) | .[]' "$CONFIG_FILE" 2>/dev/null)

# Build git diff pattern args
PATTERN_ARGS=()
for p in "${FILE_PATTERNS[@]}"; do
    PATTERN_ARGS+=("$p")
done

# Multi-phase stop: 1st stop = advisory, 2nd stop = reminder, 3rd stop = allow
if [[ -f "$STATE_FILE" ]]; then
    PHASE=$(cat "$STATE_FILE" 2>/dev/null)
    if [[ "$PHASE" == "2" ]]; then
        # Third stop (state was "2" from second stop) — always allow
        rm -f "$STATE_FILE"
        "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
        exit 0
    else
        # Phase 2: second stop — quick reminder
        echo "2" > "$STATE_FILE"
        # Build short reminder from enabled phases
        REMINDERS=()
        PHASE_REVIEW=$(jq -r '.phases.review // true' "$CONFIG_FILE")
        PHASE_TESTS=$(jq -r '.phases.tests // true' "$CONFIG_FILE")
        PHASE_DOCS=$(jq -r '.phases.docs // true' "$CONFIG_FILE")
        REVIEW_CMD=$(jq -r '.review_command // "/review-work"' "$CONFIG_FILE")
        TEST_CMD=$(jq -r '.test_command // null' "$CONFIG_FILE")
        DOCS_CMD=$(jq -r '.docs_command // "/update-docs"' "$CONFIG_FILE")
        [[ "$PHASE_REVIEW" == "true" ]] && REMINDERS+=("$REVIEW_CMD")
        [[ "$PHASE_TESTS" == "true" && "$TEST_CMD" != "null" ]] && REMINDERS+=("$TEST_CMD")
        [[ "$PHASE_DOCS" == "true" ]] && REMINDERS+=("$DOCS_CMD")
        REMINDER_STR=$(IFS=', '; echo "${REMINDERS[*]}")
        MSG="Reminder: ${REMINDER_STR} — stop again to skip."
        jq -n --arg reason "$MSG" '{"decision": "block", "reason": $reason}'
        exit 0
    fi
fi

# Get current diff (using configured file patterns)
CURRENT=$(git diff --numstat HEAD -- "${PATTERN_ARGS[@]}" 2>/dev/null || true)
[[ -z "$CURRENT" ]] && { "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true; exit 0; }

# Calculate net new changes (delta from baseline)
BASELINE_ARG="$BASELINE"
[[ ! -f "$BASELINE_ARG" ]] && BASELINE_ARG="/dev/null"

RESULT=$(awk -F'\t' '
    NR == FNR && FILENAME != "-" {
        if ($1 != "-" && $3 != "") {
            base_add[$3] = $1 + 0
            base_del[$3] = $2 + 0
        }
        next
    }
    {
        if ($1 == "-" || $1 == "" || $3 == "") next
        added = $1 + 0; deleted = $2 + 0; file = $3
        if (file in base_add) {
            delta = (added - base_add[file]) + (deleted - base_del[file])
        } else {
            delta = added + deleted
        }
        if (delta > 0) {
            total += delta
            files = files "  " file " (+" delta " lines)\n"
        }
    }
    END { print total + 0; printf "%s", files }
' "$BASELINE_ARG" - <<< "$CURRENT")

TOTAL_NEW=$(echo "$RESULT" | head -1)
FILE_LIST=$(echo "$RESULT" | tail -n +2)

# Under threshold — allow stop
if [[ $TOTAL_NEW -lt $MIN_LINES ]]; then
    "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
    exit 0
fi

# Phase 1: first stop — full advisory, mark state
echo "1" > "$STATE_FILE"

# Build advisory from enabled phases
PHASE_REVIEW=$(jq -r '.phases.review // true' "$CONFIG_FILE")
PHASE_TESTS=$(jq -r '.phases.tests // true' "$CONFIG_FILE")
PHASE_DOCS=$(jq -r '.phases.docs // true' "$CONFIG_FILE")
REVIEW_CMD=$(jq -r '.review_command // "/review-work"' "$CONFIG_FILE")
TEST_CMD=$(jq -r '.test_command // null' "$CONFIG_FILE")
DOCS_CMD=$(jq -r '.docs_command // "/update-docs"' "$CONFIG_FILE")

SUGGESTIONS=()
[[ "$PHASE_REVIEW" == "true" ]] && SUGGESTIONS+=("$REVIEW_CMD")
[[ "$PHASE_TESTS" == "true" && "$TEST_CMD" != "null" ]] && SUGGESTIONS+=("$TEST_CMD")
[[ "$PHASE_DOCS" == "true" ]] && SUGGESTIONS+=("$DOCS_CMD")
SUGGEST_STR=$(IFS=', '; echo "${SUGGESTIONS[*]}")

MSG="This session changed ${TOTAL_NEW} lines:\n${FILE_LIST}\nConsider: ${SUGGEST_STR}. Use your judgment — or stop again to skip."

jq -n --arg reason "$(printf '%b' "$MSG")" '{"decision": "block", "reason": $reason}'
exit 0
