#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_work_toggle_key="m"
default_work_menu_key="M"
default_work_stop_key="_"

work_toggle_key=$(tmux show-option -gqv @wisp_work_toggle_key)
work_menu_key=$(tmux show-option -gqv @wisp_work_menu_key)
work_stop_key=$(tmux show-option -gqv @wisp_work_stop_key)

work_toggle_key=${work_toggle_key:-$default_work_toggle_key}
work_menu_key=${work_menu_key:-$default_work_menu_key}
work_stop_key=${work_stop_key:-$default_work_stop_key}

tmux bind-key $work_toggle_key run-shell "$CURRENT_DIR/scripts/wisp-toggle.sh"
tmux bind-key $work_menu_key run-shell "$CURRENT_DIR/scripts/wisp-menu.sh"
tmux bind-key $work_stop_key run-shell "$CURRENT_DIR/scripts/wisp-stop.sh"

status_right=$(tmux show-option -gqv status-right)
if [[ "$status_right" != *"wisp-format"* ]]; then
    if command -v wisp-format >/dev/null 2>&1; then
        tmux set-option -g status-right "#(wisp-format tmux)#[fg=default,bg=default] $status_right"
    elif [ -x "$HOME/.local/bin/wisp-format" ]; then
        tmux set-option -g status-right "#($HOME/.local/bin/wisp-format tmux)#[fg=default,bg=default] $status_right"
    else
        tmux set-option -g status-right "#($CURRENT_DIR/scripts/wisp-format.sh tmux)#[fg=default,bg=default] $status_right"
    fi
fi

tmux set-option -g status-interval 1