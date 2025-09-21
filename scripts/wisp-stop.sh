#!/usr/bin/env bash

# Get notification setting from tmux if available, otherwise default to true
if [ -n "$TMUX" ]; then
    WISP_NOTIFICATIONS=$(tmux show-option -gqv @wisp_notifications)
fi
WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}"
export WISP_NOTIFICATIONS

if command -v wisp >/dev/null 2>&1; then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" wisp stop
elif [ -x "$HOME/.local/bin/wisp" ]; then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" "$HOME/.local/bin/wisp" stop
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" "$CURRENT_DIR/../bin/wisp" stop
fi