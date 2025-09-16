#!/usr/bin/env bash

if command -v wisp >/dev/null 2>&1; then
    wisp stop
elif [ -x "$HOME/.local/bin/wisp" ]; then
    "$HOME/.local/bin/wisp" stop
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    "$CURRENT_DIR/../bin/wisp" stop
fi