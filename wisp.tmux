# Wisp tmux plugin configuration

# Set default key bindings - using run-shell with inline script for configuration
run-shell 'cd "$(dirname "$0")" && {
  # Set default options if not already configured
  if [ -z "$(tmux show-option -gqv @wisp_work_toggle_key)" ]; then
    tmux set-option -g @wisp_work_toggle_key "m"
  fi
  if [ -z "$(tmux show-option -gqv @wisp_work_menu_key)" ]; then
    tmux set-option -g @wisp_work_menu_key "M"
  fi
  if [ -z "$(tmux show-option -gqv @wisp_work_stop_key)" ]; then
    tmux set-option -g @wisp_work_stop_key "_"
  fi
  if [ -z "$(tmux show-option -gqv @wisp_notifications)" ]; then
    tmux set-option -g @wisp_notifications "true"
  fi

  # Get configured keys
  work_toggle_key=$(tmux show-option -gqv @wisp_work_toggle_key)
  work_menu_key=$(tmux show-option -gqv @wisp_work_menu_key)
  work_stop_key=$(tmux show-option -gqv @wisp_work_stop_key)
  wisp_notifications=$(tmux show-option -gqv @wisp_notifications)

  # Get current directory
  CURRENT_DIR="$(pwd)"

  # Set environment variable
  tmux set-environment -g WISP_NOTIFICATIONS "$wisp_notifications"

  # Bind keys
  tmux bind-key "$work_toggle_key" run-shell "WISP_NOTIFICATIONS=\"$wisp_notifications\" \"$CURRENT_DIR/scripts/wisp-toggle.sh\""
  tmux bind-key "$work_menu_key" run-shell "WISP_NOTIFICATIONS=\"$wisp_notifications\" \"$CURRENT_DIR/scripts/wisp-menu.sh\""
  tmux bind-key "$work_stop_key" run-shell "WISP_NOTIFICATIONS=\"$wisp_notifications\" \"$CURRENT_DIR/scripts/wisp-stop.sh\""

  # Set up status line if wisp-format is not already there
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
}'

# Set status update interval
set-option -g status-interval 1