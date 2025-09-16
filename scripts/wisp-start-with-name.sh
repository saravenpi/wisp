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

WISP_CMD=$(get_wisp_cmd)
DURATION="${1:-25}"

if command -v gum >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
    SESSION_NAME=$(gum input --placeholder "Session name (optional)" --width 40 --show-help=false 2>/dev/null || echo "")
else
    echo -n "Session name (optional): "
    read SESSION_NAME
fi

if [ -n "$SESSION_NAME" ]; then
    $WISP_CMD start $DURATION "$SESSION_NAME"
else
    $WISP_CMD start $DURATION
fi