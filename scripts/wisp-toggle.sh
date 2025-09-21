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
    # No active session - ask for session name using sertren approach
    if [ -n "$TMUX" ] && command -v gum >/dev/null 2>&1; then
        # Use tmux popup with gum input directly - like sertren does
        tmux popup -w 50 -h 3 -T " Start Session " -E "
            name=\$(gum input --no-show-help --placeholder 'Session name (press Enter to skip)' --prompt 'Session > ')
            if [ \$? -eq 0 ]; then
                if [ -n \"\$name\" ]; then
                    WISP_NOTIFICATIONS=\"$WISP_NOTIFICATIONS\" \"$WISP_CMD\" start 25 \"\$name\"
                else
                    WISP_NOTIFICATIONS=\"$WISP_NOTIFICATIONS\" \"$WISP_CMD\" start 25
                fi
            fi
        "
    else
        # Fallback - just start without name
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start 25
    fi
fi