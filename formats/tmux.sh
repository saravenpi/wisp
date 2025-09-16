#!/usr/bin/env bash

format_status() {
    local status="$1"
    local display="$2"

    # Default tmux colors from the original config
    local running_fg="${wisp_running_fg:-#161617}"
    local running_bg="${wisp_running_bg:-#7fb4ca}"
    local paused_fg="${wisp_paused_fg:-#161617}"
    local paused_bg="${wisp_paused_bg:-#c4a47c}"
    local completed_fg="${wisp_completed_fg:-#c9c7cd}"
    local completed_bg="${wisp_completed_bg:-#90b99f}"
    local inactive_fg="${wisp_inactive_fg:-#c9c7cd}"
    local inactive_bg="${wisp_inactive_bg:-#353539}"

    # Get colors from tmux options if available
    running_fg=$(tmux show-option -gqv @wisp_running_fg 2>/dev/null || echo "$running_fg")
    running_bg=$(tmux show-option -gqv @wisp_running_bg 2>/dev/null || echo "$running_bg")
    paused_fg=$(tmux show-option -gqv @wisp_paused_fg 2>/dev/null || echo "$paused_fg")
    paused_bg=$(tmux show-option -gqv @wisp_paused_bg 2>/dev/null || echo "$paused_bg")
    completed_fg=$(tmux show-option -gqv @wisp_completed_fg 2>/dev/null || echo "$completed_fg")
    completed_bg=$(tmux show-option -gqv @wisp_completed_bg 2>/dev/null || echo "$completed_bg")
    inactive_fg=$(tmux show-option -gqv @wisp_inactive_fg 2>/dev/null || echo "$inactive_fg")
    inactive_bg=$(tmux show-option -gqv @wisp_inactive_bg 2>/dev/null || echo "$inactive_bg")

    case "$status" in
        "running")
            echo "#[fg=${running_fg},bg=${running_bg}] $display #[fg=${running_bg},bg=default]"
            ;;
        "paused")
            echo "#[fg=${paused_fg},bg=${paused_bg}] $display #[fg=${paused_bg},bg=default]"
            ;;
        "completed")
            echo "#[fg=${completed_fg},bg=${completed_bg}] $display #[fg=${completed_bg},bg=default]"
            ;;
        "inactive"|*)
            echo "#[fg=${inactive_fg},bg=${inactive_bg}] $display #[fg=${inactive_bg},bg=default]"
            ;;
    esac
}