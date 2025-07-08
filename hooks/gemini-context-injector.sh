#!/bin/bash
# Gemini Context Injector Hook
# Automatically adds project structure documentation to new Gemini consultation sessions
#
# This hook enhances Gemini consultations by automatically including your project's
# structure documentation, ensuring the AI has complete context about your codebase.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_STRUCTURE_FILE="$PROJECT_ROOT/docs/ai-context/project-structure.md"
LOG_FILE="$SCRIPT_DIR/../logs/context-injection.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Read input from stdin
INPUT_JSON=$(cat)

# Function to log injection events
log_injection_event() {
    local event_type="$1"
    local details="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$timestamp\", \"event\": \"$event_type\", \"details\": \"$details\"}" >> "$LOG_FILE"
}

# Main logic
main() {
    # Extract tool information from stdin
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')
    
    # Only process Gemini consultation requests
    if [[ "$tool_name" != "mcp__gemini__consult_gemini" ]]; then
        echo '{"continue": true}'
        exit 0
    fi
    
    # Extract tool arguments
    local tool_args=$(echo "$INPUT_JSON" | jq -r '.tool_input // "{}"')
    
    # Check if this is a new session (no session_id provided)
    local session_id=$(echo "$tool_args" | jq -r '.session_id // ""' 2>/dev/null || echo "")
    
    if [[ -z "$session_id" || "$session_id" == "null" ]]; then
        log_injection_event "new_session_detected" "preparing_context_injection"
        
        # Check if project structure file exists
        if [[ ! -f "$PROJECT_STRUCTURE_FILE" ]]; then
            log_injection_event "warning" "project_structure_file_not_found_at_$PROJECT_STRUCTURE_FILE"
            echo '{"continue": true}'
            exit 0
        fi
        
        # Extract current attached_files if any
        local current_files=$(echo "$tool_args" | jq -c '.attached_files // []' 2>/dev/null || echo "[]")
        
        # Check if project structure is already included
        if echo "$current_files" | jq -e ".[] | select(. == \"$PROJECT_STRUCTURE_FILE\")" > /dev/null 2>&1; then
            log_injection_event "skipped" "project_structure_already_included"
            echo '{"continue": true}'
            exit 0
        fi
        
        # Add project structure file to attached_files
        local modified_args=$(echo "$tool_args" | jq --arg file "$PROJECT_STRUCTURE_FILE" '
            .attached_files = ((.attached_files // []) + [$file])
        ' 2>/dev/null)
        
        if [[ -n "$modified_args" ]]; then
            log_injection_event "context_injected" "added_project_structure_from_$PROJECT_STRUCTURE_FILE"
            
            # Update the input JSON with modified tool_input
            local output_json=$(echo "$INPUT_JSON" | jq --argjson new_args "$modified_args" '.tool_input = $new_args')
            
            # Return the modified input to stdout
            echo "$output_json"
            exit 0
        else
            log_injection_event "error" "failed_to_modify_arguments"
            # Continue without modification on error
            echo '{"continue": true}'
            exit 0
        fi
    else
        log_injection_event "existing_session" "session_id:$session_id"
        # For existing sessions, continue without modification
        echo '{"continue": true}'
        exit 0
    fi
}

# Run main function
main