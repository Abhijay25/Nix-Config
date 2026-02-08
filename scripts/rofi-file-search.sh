#!/usr/bin/env bash
# Rofi file search - opens terminal in file's directory

CACHE_FILE="/tmp/rofi-file-cache"
CACHE_MAX_AGE=300  # 5 minutes

if [ -z "$1" ]; then
    # Check if cache exists and is fresh
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
        cat "$CACHE_FILE"
    else
        # Generate fresh cache
        if command -v fd &> /dev/null; then
            fd --type f --hidden --max-depth 6 \
               --exclude .git --exclude node_modules \
               --exclude .cache --exclude .nix-defexpr --exclude .nix-profile \
               --exclude .local/share --exclude .mozilla --exclude .cargo \
               --base-directory "$HOME" 2>/dev/null | tee "$CACHE_FILE"
        else
            find "$HOME" -maxdepth 6 -type f \
                -not -path '*/.git/*' \
                -not -path '*/node_modules/*' \
                -not -path '*/.cache/*' \
                2>/dev/null | sed "s|$HOME/||" | tee "$CACHE_FILE"
        fi
    fi
else
    # User selected a file - open terminal in its directory
    selected="$HOME/$1"
    if [ -f "$selected" ]; then
        dir=$(dirname "$selected")
        nohup ghostty --working-directory="$dir" >/dev/null 2>&1 &
        disown
    fi
    exit 0
fi
