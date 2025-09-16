#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default key bindings
default_work_toggle_key="m"
default_work_menu_key="M"
default_work_stop_key="_"

# Get key bindings from tmux options or use defaults
work_toggle_key=$(tmux show-option -gqv @wisp_work_toggle_key)
work_menu_key=$(tmux show-option -gqv @wisp_work_menu_key)
work_stop_key=$(tmux show-option -gqv @wisp_work_stop_key)

work_toggle_key=${work_toggle_key:-$default_work_toggle_key}
work_menu_key=${work_menu_key:-$default_work_menu_key}
work_stop_key=${work_stop_key:-$default_work_stop_key}

# Set up key bindings
tmux bind-key $work_toggle_key run-shell "$CURRENT_DIR/scripts/wisp-toggle.sh"
tmux bind-key $work_menu_key run-shell "$CURRENT_DIR/scripts/wisp-menu.sh"
tmux bind-key $work_stop_key run-shell "$CURRENT_DIR/scripts/wisp-stop.sh"

# Add wisp status to status-right if not already present
status_right=$(tmux show-option -gqv status-right)
if [[ "$status_right" != *"wisp-format"* ]]; then
    tmux set-option -g status-right "#($CURRENT_DIR/scripts/wisp-format.sh tmux)#[fg=default,bg=default] $status_right"
fi

# Set status interval for live updates
tmux set-option -g status-interval 1