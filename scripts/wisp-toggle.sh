#!/usr/bin/env bash

if command -v wisp >/dev/null 2>&1; then
    wisp toggle
elif [ -x "$HOME/.local/bin/wisp" ]; then
    "$HOME/.local/bin/wisp" toggle
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    "$CURRENT_DIR/../bin/wisp" toggle
fi