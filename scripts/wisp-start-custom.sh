#!/usr/bin/env bash

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

# Simplified approach - get both inputs in sequence
if [ -n "$TMUX" ]; then
    # Use simple sequential prompts instead of nested popups
    printf "Duration > "
    read -r DURATION

    if [ -n "$DURATION" ]; then
        clear
        printf "Session > "
        read -r SESSION_NAME

        # Start the session with duration and name (empty is allowed)
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"

        # Force immediate tmux status refresh after session creation
        if [ -n "$TMUX" ]; then
            sleep 0.2
            tmux refresh-client -S >/dev/null 2>&1
            tmux refresh-client >/dev/null 2>&1
        fi
    fi
else
    # Fallback to standard read
    printf "Duration > "
    read -r DURATION
    if [ -n "$DURATION" ]; then
        printf "Session > "
        read -r SESSION_NAME
        # Always pass session name (empty is allowed)
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"

        # Force immediate tmux status refresh after session creation
        if [ -n "$TMUX" ]; then
            sleep 0.2
            tmux refresh-client -S >/dev/null 2>&1
            tmux refresh-client >/dev/null 2>&1
        fi
    fi
fi
