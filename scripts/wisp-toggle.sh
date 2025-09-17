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
WORK_LOG="$HOME/.wisp.yml"

if [ -f "$WORK_LOG" ] && (grep -q "status: in_progress" "$WORK_LOG" 2>/dev/null || grep -q "status: paused" "$WORK_LOG" 2>/dev/null); then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD toggle
else
    if [ -n "$TMUX" ]; then
        if command -v gum >/dev/null 2>&1; then
            tmux display-popup -x C -y C -w 50 -h 3 -E "
                name=\$(gum input --no-show-help --placeholder 'Session name (press Enter to skip)' --prompt 'Session > ' --width 40)
                if [ \$? -eq 0 ] && [ -n \"\$name\" ]; then
                    WISP_NOTIFICATIONS=\"${WISP_NOTIFICATIONS:-true}\" $WISP_CMD start 25 \"\$name\"
                else
                    WISP_NOTIFICATIONS=\"${WISP_NOTIFICATIONS:-true}\" $WISP_CMD start 25
                fi
            "
        else
            tmux command-prompt -p "Session name (Enter to skip):" "run-shell 'WISP_NOTIFICATIONS=\"${WISP_NOTIFICATIONS:-true}\" $WISP_CMD start 25 \"%%\"'"
        fi
    else
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD toggle
    fi
fi