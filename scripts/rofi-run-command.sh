#!/usr/bin/env bash

HISTORY_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-terminal-history"
MAX_HISTORY=5

# Ensure history file exists
touch "$HISTORY_FILE"

if [ -z "$1" ]; then
    # Show history (most recent first, deduplicated)
    echo -en "\0no-custom\x1ffalse\n"
    tac "$HISTORY_FILE" | awk '!seen[$0]++' | head -n "$MAX_HISTORY"
else
    # Save command to history (append to end)
    echo "$1" >> "$HISTORY_FILE"

    # Trim history file if too large
    tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

    # Execute command
    nohup ghostty -e zsh -ic "$1; exec zsh -i" >/dev/null 2>&1 &
    disown
    exit 0
fi
