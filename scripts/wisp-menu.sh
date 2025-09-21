#!/usr/bin/env bash

WORK_LOG="$HOME/.wisp.yml"

if [ -z "$TMUX" ]; then
    echo "Error: This menu must be run from within tmux"
    exit 1
fi

# Get notification setting from tmux if available, otherwise default to true
if [ -n "$TMUX" ]; then
    WISP_NOTIFICATIONS=$(tmux show-option -gqv @wisp_notifications)
fi
WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}"
export WISP_NOTIFICATIONS

has_active_session=false
session_status=""

get_wisp_cmd() {
    if command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
    fi
}

get_wisp_format_cmd() {
    if command -v wisp-format >/dev/null 2>&1; then
        echo "wisp-format"
    elif [ -x "$HOME/.local/bin/wisp-format" ]; then
        echo "$HOME/.local/bin/wisp-format"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/wisp-format.sh"
    fi
}

WISP_CMD=$(get_wisp_cmd)
WISP_FORMAT_CMD=$(get_wisp_format_cmd)

if [ -f "$WORK_LOG" ]; then
    if grep -q "status: in_progress" "$WORK_LOG" 2>/dev/null; then
        timer_status=$($WISP_FORMAT_CMD default)
        if [[ "$timer_status" == *"Inactive"* ]]; then
            has_active_session=false
        else
            has_active_session=true
            session_status="running"
        fi
    elif grep -q "status: paused" "$WORK_LOG" 2>/dev/null; then
        has_active_session=true
        session_status="paused"
    fi
fi

if [ "$has_active_session" = true ]; then
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    if [ "$session_status" = "running" ]; then
        tmux display-menu -x C -y C -T " Wisp " \
            "Name Session" n "display-popup -x C -y C -w 50 -h 3 -T ' Name Session ' -E '$CURRENT_DIR/wisp-name-session.sh'" \
            "Pause Session" p "run-shell 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/../bin/wisp pause'" \
            "" \
            "Stop Session" s "run-shell 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/../bin/wisp stop'" \
            "" \
            "Show History" h "display-popup -x C -y C -w 90 -h 25 -S -E '$CURRENT_DIR/../bin/wisp history; echo; echo \"Press any key to close...\"; read -n 1'" \
            "Show Stats" t "display-popup -x C -y C -w 70 -h 20 -S -E '$CURRENT_DIR/../bin/wisp stats; echo; echo \"Press any key to close...\"; read -n 1'"
    elif [ "$session_status" = "paused" ]; then
        tmux display-menu -x C -y C -T " Wisp " \
            "Name Session" n "display-popup -x C -y C -w 50 -h 3 -T ' Name Session ' -E '$CURRENT_DIR/wisp-name-session.sh'" \
            "Resume Session" r "run-shell 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/../bin/wisp resume'" \
            "" \
            "Stop Session" s "run-shell 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/../bin/wisp stop'" \
            "" \
            "Show History" h "display-popup -x C -y C -w 90 -h 25 -S -E '$CURRENT_DIR/../bin/wisp history; echo; echo \"Press any key to close...\"; read -n 1'" \
            "Show Stats" t "display-popup -x C -y C -w 70 -h 20 -S -E '$CURRENT_DIR/../bin/wisp stats; echo; echo \"Press any key to close...\"; read -n 1'"
    fi
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    tmux display-menu -x C -y C -T " Wisp " \
        "Start 25min Session" 1 "display-popup -x C -y C -w 50 -h 3 -E 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/wisp-start-with-name.sh 25'" \
        "Start 45min Session" 2 "display-popup -x C -y C -w 50 -h 3 -E 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/wisp-start-with-name.sh 45'" \
        "Start Custom Session" s "display-popup -x C -y C -w 50 -h 3 -E 'WISP_NOTIFICATIONS=\"\${WISP_NOTIFICATIONS:-true}\" $CURRENT_DIR/wisp-start-custom.sh'" \
        "" \
        "Show History" h "display-popup -x C -y C -w 90 -h 25 -S -E '$CURRENT_DIR/../bin/wisp history; echo; echo \"Press any key to close...\"; read -n 1'" \
        "Show Stats" t "display-popup -x C -y C -w 70 -h 20 -S -E '$CURRENT_DIR/../bin/wisp stats; echo; echo \"Press any key to close...\"; read -n 1'"
fi