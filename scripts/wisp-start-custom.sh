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

# Check if gum is available and we're in tmux
if [ -n "$TMUX" ] && command -v gum >/dev/null 2>&1; then
    # Use tmux popup to get the duration, write to temp file
    temp_file="/tmp/wisp-duration-$$"

    # Run popup to get duration - compact height
    if tmux popup -w 40 -h 3 -T " Duration " -E "
        duration=\$(gum input --no-show-help --placeholder 'Duration in minutes' --prompt 'Duration > ')
        if [ \$? -eq 0 ]; then
            echo \"\$duration\" > '$temp_file'
        fi
    "; then
        # Popup succeeded, check if we have a duration
        if [ -f "$temp_file" ]; then
            DURATION=$(head -1 "$temp_file")
            rm -f "$temp_file"

            if [ -n "$DURATION" ]; then
                # Get session name with another compact popup
                temp_file2="/tmp/wisp-session-$$"

                if tmux popup -w 50 -h 3 -T " Session Name " -E "
                    name=\$(gum input --no-show-help --placeholder 'Session name (press Enter to skip)' --prompt 'Session > ')
                    if [ \$? -eq 0 ]; then
                        echo \"\$name\" > '$temp_file2'
                    fi
                "; then
                    if [ -f "$temp_file2" ]; then
                        SESSION_NAME=$(head -1 "$temp_file2")
                        rm -f "$temp_file2"

                        # Start the session with duration and optional name
                        if [ -n "$SESSION_NAME" ]; then
                            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"
                        else
                            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION"
                        fi

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
    printf "Duration > " >&2
    IFS= read -r DURATION
    if [ -n "$DURATION" ]; then
        printf "Session > " >&2
        IFS= read -r SESSION_NAME
        if [ -n "$SESSION_NAME" ]; then
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION" "$SESSION_NAME"
        else
            WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" $WISP_CMD start "$DURATION"
        fi

        # Force immediate tmux status refresh after session creation
        if [ -n "$TMUX" ]; then
            sleep 0.2  # Slightly longer pause to ensure session is fully created
            tmux refresh-client -S >/dev/null 2>&1
            tmux refresh-client >/dev/null 2>&1  # Double refresh for immediate update
        fi
    fi
fi
