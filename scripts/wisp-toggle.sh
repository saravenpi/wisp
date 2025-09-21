#!/usr/bin/env bash

get_wisp_cmd() {
    if command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
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
    if [ -n "$TMUX" ] && command -v gum >/dev/null 2>&1; then
        # Use tmux popup to get the session name, write to temp file
        local temp_file="/tmp/wisp-session-name-$$"

        # Run popup to get session name - popup closes immediately after input
        if tmux popup -w 50 -h 3 -T " Start Session " -E "
            name=\$(gum input --no-show-help --placeholder 'Session name (press Enter to skip)' --prompt 'Session > ')
            if [ \$? -eq 0 ]; then
                echo \"\$name\" > '$temp_file'
            fi
        "; then
            # Popup succeeded, check if we have a result
            if [ -f "$temp_file" ]; then
                session_name=$(cat "$temp_file")
                rm -f "$temp_file"

                # Start the session outside the popup
                if [ -n "$session_name" ]; then
                    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25 "$session_name"
                else
                    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25
                fi
            fi
        else
            # Popup was cancelled, clean up temp file
            rm -f "$temp_file"
        fi
    else
        # Fallback - just start without name
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25
    fi
fi