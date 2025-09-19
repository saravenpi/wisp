#!/bin/bash

# Wisp utility functions
# Shared functions for consistent user interactions across all wisp scripts

# Unified name prompting function with gum/tmux fallback
# Usage: prompt_for_name "placeholder text" "prompt text" [width]
# Returns: input string, or exits with code 1 if cancelled (escape pressed)
prompt_for_name() {
    local placeholder="$1"
    local prompt="$2"
    local width="${3:-40}"
    local result=""

    # Try gum first if available and we have proper terminal access
    if command -v gum >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
        # Try gum with proper error handling for tmux environments
        result=$(gum input --no-show-help --placeholder "$placeholder" --prompt "$prompt" --width "$width" 2>/dev/null)
        local exit_code=$?

        # If gum was cancelled (escape pressed), exit with error
        if [ $exit_code -ne 0 ]; then
            return 1
        fi
    else
        # Fallback to standard read for tmux environments or when gum is unavailable
        # Use read with timeout to allow escape detection
        if ! read -p "$prompt" result; then
            # Handle Ctrl+C or other interruptions
            return 1
        fi
    fi

    echo "$result"
}