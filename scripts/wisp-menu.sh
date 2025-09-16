#!/usr/bin/env bash

WORK_LOG="$HOME/.wisp.yml"

if [ -z "$TMUX" ]; then
    echo "Error: This menu must be run from within tmux"
    exit 1
fi

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
    if [ "$session_status" = "running" ]; then
        tmux display-menu -x C -y C -T " Wisp " \
            "Name Session" n "display-popup -x C -y C -w 40 -h 3 -T ' Name Session ' -E 'if command -v gum >/dev/null 2>&1; then name=\$(gum input --no-show-help --placeholder \"Session name\" --prompt \"Session > \" --width 30); else echo -n \"Session name: \"; read name; fi; if [ -n \"\$name\" ]; then $WISP_CMD name \"\$name\"; fi; read -p \"Press Enter to continue...\"'" \
            "Pause Session" p "run-shell '$WISP_CMD pause'" \
            "" \
            "Stop Session" s "run-shell '$WISP_CMD stop'" \
            "" \
            "Show History" h "display-popup -x C -y C -w 80 -h 20 -E '$WISP_CMD history'" \
            "Show Stats" t "display-popup -x C -y C -w 60 -h 15 -E '$WISP_CMD stats'"
    elif [ "$session_status" = "paused" ]; then
        tmux display-menu -x C -y C -T " Wisp " \
            "Name Session" n "display-popup -x C -y C -w 40 -h 3 -T ' Name Session ' -E 'if command -v gum >/dev/null 2>&1; then name=\$(gum input --no-show-help --placeholder \"Session name\" --prompt \"Session > \" --width 30); else echo -n \"Session name: \"; read name; fi; if [ -n \"\$name\" ]; then $WISP_CMD name \"\$name\"; fi; read -p \"Press Enter to continue...\"'" \
            "Resume Session" r "run-shell '$WISP_CMD resume'" \
            "" \
            "Stop Session" s "run-shell '$WISP_CMD stop'" \
            "" \
            "Show History" h "display-popup -x C -y C -w 80 -h 20 -E '$WISP_CMD history'" \
            "Show Stats" t "display-popup -x C -y C -w 60 -h 15 -E '$WISP_CMD stats'"
    fi
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    tmux display-menu -x C -y C -T " Wisp " \
        "Start 25min Session" 1 "display-popup -x C -y C -w 50 -h 3 -E '$CURRENT_DIR/wisp-start-with-name.sh 25'" \
        "Start 45min Session" 2 "display-popup -x C -y C -w 50 -h 3 -E '$CURRENT_DIR/wisp-start-with-name.sh 45'" \
        "Start Custom Session" s "command-prompt -p 'Duration (minutes):' 'display-popup -x C -y C -w 50 -h 3 -E \"$CURRENT_DIR/wisp-start-with-name.sh %1\"'" \
        "" \
        "Show History" h "display-popup -x C -y C -w 80 -h 20 -E '$WISP_CMD history'" \
        "Show Stats" t "display-popup -x C -y C -w 60 -h 15 -E '$WISP_CMD stats'"
fi