#!/bin/bash
# stop-pipeline.sh — Stop hook pipeline: Review -> Tests (if configured) -> Docs
# State machine with session-scoped state file. Each phase fires exactly once.
# Configuration: hooks/config/pipeline.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_INPUT=$(cat)
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# Use project path hash for state file (session_id may not be available in Stop hooks)
STATE_ID=$(echo "$PROJECT_DIR" | md5sum 2>/dev/null | cut -c1-12 || echo "$PROJECT_DIR" | md5 -q 2>/dev/null || echo "default")
STATE_FILE="/tmp/claude-pipeline-${STATE_ID}.state"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Load configuration
CONFIG_FILE="$SCRIPT_DIR/config/pipeline.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0  # No config = no pipeline
fi

ENABLED=$(jq -r '.enabled // true' "$CONFIG_FILE")
[[ "$ENABLED" != "true" ]] && exit 0

MIN_LINES=$(jq -r '.min_lines_changed // 10' "$CONFIG_FILE")
PHASE_REVIEW=$(jq -r '.phases.review // true' "$CONFIG_FILE")
PHASE_TESTS=$(jq -r '.phases.tests // true' "$CONFIG_FILE")
PHASE_DOCS=$(jq -r '.phases.docs // true' "$CONFIG_FILE")
TEST_COMMAND=$(jq -r '.test_command // null' "$CONFIG_FILE")

TEST_FILE_PATTERNS=$(jq -r '.test_file_patterns // ["*.ts","*.py","*.js"] | .[]' "$CONFIG_FILE" 2>/dev/null)

# Helper: emit block JSON and exit
block() {
    jq -n --arg reason "$1" '{"decision": "block", "reason": $reason}'
    exit 0
}

# Read current phase (empty string = initial)
PHASE=""
[[ -f "$STATE_FILE" ]] && PHASE=$(cat "$STATE_FILE")

case "$PHASE" in

    "") # -- Phase 0: Check if pipeline should activate --
        # Count changed lines across configured file patterns
        TOTAL_CHANGED=0
        PATTERNS=$(jq -r '(.file_patterns // ["*.py","*.ts","*.js","*.swift","*.go","*.rs"]) | .[]' "$CONFIG_FILE")
        while IFS= read -r pattern; do
            DIFF_OUTPUT=$(git diff --numstat HEAD -- "$pattern" 2>/dev/null || true)
            while IFS=$'\t' read -r added deleted _file; do
                [[ -z "$added" || "$added" == "-" ]] && continue
                TOTAL_CHANGED=$((TOTAL_CHANGED + added + deleted))
            done <<< "$DIFF_OUTPUT"
        done <<< "$PATTERNS"

        if [[ $TOTAL_CHANGED -lt $MIN_LINES ]]; then
            "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
            exit 0
        fi

        if [[ "$PHASE_REVIEW" == "true" ]]; then
            echo "review" > "$STATE_FILE"
            block "You have $TOTAL_CHANGED lines of uncommitted changes. Invoke /review-work now to run a code review before finishing."
        elif [[ "$PHASE_TESTS" == "true" && "$TEST_COMMAND" != "null" ]]; then
            echo "tests" > "$STATE_FILE"
            block "You have $TOTAL_CHANGED lines of uncommitted changes. Run tests now: \`$TEST_COMMAND\`"
        elif [[ "$PHASE_DOCS" == "true" ]]; then
            echo "docs" > "$STATE_FILE"
            block "You have $TOTAL_CHANGED lines of uncommitted changes. Invoke /update-docs now to update project documentation."
        else
            "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
            exit 0
        fi
        ;;

    "review") # -- Phase 1 done. Tests needed? --
        if [[ "$PHASE_TESTS" == "true" && "$TEST_COMMAND" != "null" ]]; then
            # Check if any test-relevant files changed
            HAS_TEST_FILES=false
            while IFS= read -r pattern; do
                if git diff --name-only HEAD -- "$pattern" 2>/dev/null | grep -q .; then
                    HAS_TEST_FILES=true
                    break
                fi
            done <<< "$TEST_FILE_PATTERNS"

            if [[ "$HAS_TEST_FILES" == "true" ]]; then
                echo "tests" > "$STATE_FILE"
                block "Review complete. Run tests now: \`$TEST_COMMAND\`. Fix any failures before stopping."
            else
                if [[ "$PHASE_DOCS" == "true" ]]; then
                    echo "docs" > "$STATE_FILE"
                    block "Review complete. Invoke /update-docs now to update project documentation."
                else
                    rm -f "$STATE_FILE"
                    "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
                    exit 0
                fi
            fi
        elif [[ "$PHASE_DOCS" == "true" ]]; then
            echo "docs" > "$STATE_FILE"
            block "Review complete. Invoke /update-docs now to update project documentation."
        else
            rm -f "$STATE_FILE"
            "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
            exit 0
        fi
        ;;

    "tests") # -- Phase 2 done. Move to docs. --
        if [[ "$PHASE_DOCS" == "true" ]]; then
            echo "docs" > "$STATE_FILE"
            block "Tests complete. Invoke /update-docs now to update project documentation."
        else
            rm -f "$STATE_FILE"
            "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
            exit 0
        fi
        ;;

    "docs") # -- Phase 3 done. Pipeline complete. --
        rm -f "$STATE_FILE"
        "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
        exit 0
        ;;

    *) # -- Unknown state — clean up and allow stop --
        rm -f "$STATE_FILE"
        "$SCRIPT_DIR/notify.sh" complete 2>/dev/null || true
        exit 0
        ;;
esac
