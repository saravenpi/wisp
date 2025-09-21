#!/usr/bin/env bash

get_wisp_cmd() {
    # Prefer local development version first
    local_wisp="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
    if [ -x "$local_wisp" ]; then
        echo "$local_wisp"
    elif command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$local_wisp"
    fi
}

# Get notification setting from tmux if available, otherwise default to true
if [ -n "$TMUX" ]; then
    WISP_NOTIFICATIONS=$(tmux show-option -gqv @wisp_notifications)
fi
WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}"
export WISP_NOTIFICATIONS

WISP_CMD=$(get_wisp_cmd)
WORK_LOG="$HOME/.wisp.yml"

if [ -f "$WORK_LOG" ] && (grep -q "status: in_progress" "$WORK_LOG" 2>/dev/null || grep -q "status: paused" "$WORK_LOG" 2>/dev/null); then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD toggle
else
    # No active session - ask for session name using popup, then start outside
    if [ -n "$TMUX" ]; then
        # Use tmux popup to get the session name, write to temp file
        temp_file="/tmp/wisp-session-name-$$"

        # Run popup to get session name
        if tmux popup -w 50 -h 3 -T " Start Session " -E "
            printf 'Session (Enter=empty, Esc=cancel) > '
            # Enable raw mode to capture escape sequences
            if read -r name; then
                echo \"\$name\" > '$temp_file'
                exit 0
            else
                # Read was interrupted (Ctrl+C, Esc, etc.)
                exit 1
            fi
        "; then
            # Popup succeeded, check if we have a result
            if [ -f "$temp_file" ]; then
                # Get the session name (first line of temp file)
                session_name=$(head -1 "$temp_file")
                rm -f "$temp_file"

                # Start the session outside the popup - always allow empty names
                WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25 "$session_name"
            fi
        else
            # Popup was cancelled, clean up temp file
            rm -f "$temp_file"
        fi
    else
        # Fallback - pass empty string explicitly to avoid prompting
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25 ""
    fi
fi