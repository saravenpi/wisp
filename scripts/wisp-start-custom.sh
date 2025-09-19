#!/usr/bin/env bash

# Source shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/wisp-utils.sh"

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

echo "🕒 Custom Session Setup"
echo

if ! DURATION=$(prompt_for_name "Duration in minutes" "Duration > " 30); then
    echo "❌ Cancelled"
    exit 0
fi

if [ -n "$DURATION" ]; then
    echo
    if SESSION_NAME=$(prompt_for_name "Session name (press Enter to skip)" "Session > " 40); then
        echo
        if [ -n "$SESSION_NAME" ]; then
            echo "Starting ${DURATION}min session: $SESSION_NAME"
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"
        else
            echo "Starting ${DURATION}min session"
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION"
        fi

        echo "✅ Session started successfully!"

        # Force immediate tmux status refresh after session creation
        if [ -n "$TMUX" ]; then
            sleep 0.2  # Slightly longer pause to ensure session is fully created
            tmux refresh-client -S >/dev/null 2>&1
            tmux refresh-client >/dev/null 2>&1  # Double refresh for immediate update
        fi
    else
        echo "❌ Cancelled"
    fi
else
    echo "❌ No duration provided"
fi

echo
read -p "Press Enter to close..."
