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

if name=$(prompt_for_name "Session name" "Session > " 40); then
    if [ -n "$name" ]; then
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD name "$name"
    fi
fi