#!/bin/bash

# Wisp utility functions
# Shared functions for consistent user interactions across all wisp scripts

# Unified name prompting function with tmux popup and gum/fallback support
# Usage: prompt_for_name "placeholder text" "prompt text" [width]
prompt_for_name() {
    local placeholder="$1"
    local prompt="$2"
    local width="${3:-40}"
    local result=""

    # Try gum directly if available and we have proper terminal access
    if command -v gum >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
        # Use gum input with proper error handling
        if result=$(gum input --no-show-help --placeholder "$placeholder" --prompt "$prompt" --width "$width" 2>/dev/null); then
            echo "$result"
            return 0
        fi
    fi

    # Fallback to standard read when gum is unavailable or fails
    printf "%s" "$prompt" >&2
    IFS= read -r result

    # Enhanced escape sequence and cancellation detection
    case "$result" in
        # Check for ESC key combinations
        $'\x1b'*|$'\033'*|$'\x1b'|$'\033')
            return 1
            ;;
        # Check for Ctrl+C
        $'\x03')
            return 1
            ;;
        # Check for Ctrl+D (EOF)
        $'\x04')
            return 1
            ;;
        # Empty result after trim is OK
        *)
            # Trim whitespace and return result
            result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            echo "$result"
            return 0
            ;;
    esac
}