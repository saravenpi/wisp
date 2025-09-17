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

if command -v gum >/dev/null 2>&1; then
    DURATION=$(gum input --no-show-help --placeholder "Duration in minutes" --prompt "Duration > " --width 30 2>/dev/null || echo "")
    if [ -n "$DURATION" ]; then
        SESSION_NAME=$(gum input --no-show-help --placeholder "Session name (press Enter to skip)" --prompt "Session > " --width 40 2>/dev/null || echo "")
        if [ -n "$SESSION_NAME" ]; then
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"
        else
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION"
        fi
    fi
else
    echo -n "Duration in minutes: "
    read DURATION
    if [ -n "$DURATION" ]; then
        echo -n "Session name (press Enter to skip): "
        read SESSION_NAME
        if [ -n "$SESSION_NAME" ]; then
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"
        else
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION"
        fi
    fi
fi