#!/bin/bash

# Wisp utility functions
# Shared functions for consistent user interactions across all wisp scripts

# Unified name prompting function with simple shell input
# Usage: prompt_for_name "placeholder text" "prompt text"
prompt_for_name() {
    local placeholder="$1"
    local prompt="$2"
    local result=""

    # Use simple shell input for reliability
    printf "%s" "$prompt"
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