#!/usr/bin/env bash

# Get notification setting from tmux if available, otherwise default to true
if [ -n "$TMUX" ]; then
    WISP_NOTIFICATIONS=$(tmux show-option -gqv @wisp_notifications)
fi
WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}"
export WISP_NOTIFICATIONS

get_wisp_cmd() {
    if command -v wisp >/dev/null 2>&1; then
        echo "wisp"
    elif [ -x "$HOME/.local/bin/wisp" ]; then
        echo "$HOME/.local/bin/wisp"
    else
        echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../bin/wisp"
    fi
}

WISP_CMD=$(get_wisp_cmd)

# Use tmux popup with simple read for input
if [ -n "$TMUX" ]; then
    # Use tmux popup to get the duration, write to temp file
    temp_file="/tmp/wisp-duration-$$"

    # Run popup to get duration
    if tmux popup -w 40 -h 3 -T " Duration " -E "
        printf 'Duration (Esc=cancel) > '
        if read -r duration; then
            echo \"\$duration\" > '$temp_file'
            exit 0
        else
            exit 1
        fi
    "; then
        # Popup succeeded, check if we have a duration
        if [ -f "$temp_file" ]; then
            DURATION=$(head -1 "$temp_file")
            rm -f "$temp_file"

            if [ -n "$DURATION" ]; then
                # Get session name with another popup
                temp_file2="/tmp/wisp-session-$$"

                if tmux popup -w 50 -h 3 -T " Session Name " -E "
                    printf 'Session (Enter=empty, Esc=cancel) > '
                    if read -r name; then
                        echo \"\$name\" > '$temp_file2'
                        exit 0
                    else
                        exit 1
                    fi
                "; then
                    if [ -f "$temp_file2" ]; then
                        SESSION_NAME=$(head -1 "$temp_file2")
                        rm -f "$temp_file2"

                        # Start the session with duration and name (empty is allowed)
                        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"

                        # Force immediate tmux status refresh after session creation
                        sleep 0.2
                        tmux refresh-client -S >/dev/null 2>&1
                        tmux refresh-client >/dev/null 2>&1
                    fi
                else
                    rm -f "$temp_file2"
                fi
            fi
        fi
    else
        rm -f "$temp_file"
    fi
else
    # Fallback to standard read
    printf "Duration > "
    read -r DURATION
    if [ -n "$DURATION" ]; then
        printf "Session > "
        read -r SESSION_NAME
        # Always pass session name (empty is allowed)
        WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"

        # Force immediate tmux status refresh after session creation
        if [ -n "$TMUX" ]; then
            sleep 0.2
            tmux refresh-client -S >/dev/null 2>&1
            tmux refresh-client >/dev/null 2>&1
        fi
    fi
fi
