#!/usr/bin/env bash

get_wisp_cmd() {
    if command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
    fi
}

# Standardized gum input with tmux popup compatibility
get_gum_input() {
    local placeholder="$1"
    local prompt="$2"
    local width="${3:-40}"

    if command -v gum >/dev/null 2>&1; then
        # Try gum first, with proper error handling for tmux environments
        local result
        result=$(gum input --no-show-help --placeholder "$placeholder" --prompt "$prompt" --width "$width" 2>/dev/null)
        local exit_code=$?

        # If gum fails (e.g., in tmux popup), fall back to read
        if [ $exit_code -eq 0 ]; then
            echo "$result"
            return 0
        fi
    fi

    # Fallback to standard read
    echo -n "$prompt"
    read -r result
    echo "$result"
}

WISP_CMD=$(get_wisp_cmd)

echo "📝 Name Current Session"
echo

name=$(get_gum_input "Session name" "Session > " 40)

if [ -n "$name" ]; then
    echo
    echo "Naming session: $name"
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD name "$name"
    echo "✅ Session named successfully!"
else
    echo "❌ No name provided"
fi

echo
read -p "Press Enter to continue..."