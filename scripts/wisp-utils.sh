#!/bin/bash

# Wisp utility functions
# Shared functions for consistent user interactions across all wisp scripts

# Unified name prompting function with gum/tmux fallback
# Usage: prompt_for_name "placeholder text" "prompt text" [width]
prompt_for_name() {
    local placeholder="$1"
    local prompt="$2"
    local width="${3:-40}"
    local result=""

    if command -v gum >/dev/null 2>&1; then
        # Try gum first, with proper error handling for tmux environments
        result=$(gum input --no-show-help --placeholder "$placeholder" --prompt "$prompt" --width "$width" 2>/dev/null)
        local exit_code=$?

        # If gum succeeds, return the result
        if [ $exit_code -eq 0 ]; then
            echo "$result"
            return 0
        fi
    fi

    # Fallback to standard read for tmux environments or when gum is not available
    echo -n "$prompt"
    read -r result
    echo "$result"
}