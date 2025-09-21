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

    # If we're in tmux and gum is available, use tmux popup for clean floating interface
    if [ -n "$TMUX" ] && command -v gum >/dev/null 2>&1; then
        # Use tmux popup with gum input - this provides proper escape key handling
        local popup_width=$((width + 5))
        local popup_height=3
        local title=" Wisp Input "
        local temp_file="/tmp/wisp-input-$$"

        # Run gum input inside tmux popup using temporary file approach like sertren
        if tmux popup -w "$popup_width" -h "$popup_height" -T "$title" -E "
            result=\$(gum input --no-show-help --placeholder '$placeholder' --prompt '$prompt')
            if [ \$? -eq 0 ]; then
                echo \"\$result\" > '$temp_file'
            fi
        "; then
            # Popup completed successfully, check if we have a result
            if [ -f "$temp_file" ]; then
                result=$(cat "$temp_file")
                rm -f "$temp_file"
                echo "$result"
                return 0
            else
                # Popup was cancelled or no input provided
                rm -f "$temp_file"
                return 1
            fi
        else
            # Popup was cancelled (escape key pressed)
            rm -f "$temp_file"
            return 1
        fi
    fi

    # Try gum directly if available and we have proper terminal access (non-tmux fallback)
    if command -v gum >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
        # Attempt gum with proper error handling and timeout
        if result=$(timeout 5 gum input --no-show-help --placeholder "$placeholder" --prompt "$prompt" --width "$width" 2>/dev/null); then
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