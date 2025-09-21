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
    # No active session - start a new 25-minute session without asking for a name
    # Use the menu (prefix + W) if you want to specify a custom name
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25
fi