#!/usr/bin/env bash

format_status() {
    local status="$1"
    local display="$2"

    case "$status" in
        "running")
            echo "▶ ${display#* }"
            ;;
        "paused")
            echo "⏸ ${display#* }"
            ;;
        "completed"|"inactive"|*)
            echo "●"
            ;;
    esac
}