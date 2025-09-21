#!/usr/bin/env bash

# Source shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/wisp-utils.sh"

# Get notification setting from tmux if available, otherwise default to true
if [ -n "$TMUX" ]; then
    WISP_NOTIFICATIONS=$(tmux show-option -gqv @wisp_notifications)
fi
WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}"
export WISP_NOTIFICATIONS

get_wisp_cmd() {
    if command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
    fi
}

WISP_CMD=$(get_wisp_cmd)
DURATION="${1:-25}"

if SESSION_NAME=$(prompt_for_name "Session name (press Enter to skip)" "Session > " 40); then
    if [ -n "$SESSION_NAME" ]; then
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start $DURATION "$SESSION_NAME"
    else
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start $DURATION
    fi
else
    exit 0
fi

# Force immediate tmux status refresh after session creation
if [ -n "$TMUX" ]; then
    sleep 0.2  # Slightly longer pause to ensure session is fully created
    tmux refresh-client -S >/dev/null 2>&1
    tmux refresh-client >/dev/null 2>&1  # Double refresh for immediate update
fi
