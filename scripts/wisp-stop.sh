#!/usr/bin/env bash

if command -v wisp >/dev/null 2>&1; then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" wisp stop
elif [ -x "$HOME/.local/bin/wisp" ]; then
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" "$HOME/.local/bin/wisp" stop
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    WISP_NOTIFICATIONS="${WISP_NOTIFICATIONS:-true}" "$CURRENT_DIR/../bin/wisp" stop
fi