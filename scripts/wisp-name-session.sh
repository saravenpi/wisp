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

# Check if gum is available
if command -v gum >/dev/null 2>&1; then
    # Get the session name using gum input - the tmux popup handles escape properly
    name=$(gum input --no-show-help --placeholder "Session name" --prompt "Session > ")

    # Check if gum was cancelled (escape key pressed)
    if [ $? -eq 0 ]; then
        if [ -n "$name" ]; then
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD name "$name"
        fi
    else
        # User pressed escape - exit gracefully
        exit 0
    fi
else
    # Fallback to standard read
    printf "Session > " >&2
    IFS= read -r name
    if [ -n "$name" ]; then
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD name "$name"
    fi
fi