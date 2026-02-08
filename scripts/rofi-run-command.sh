#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo -en "\0no-custom\x1ffalse\n"
else
    nohup ghostty -e bash -c "$1; echo ''; echo 'Press Enter to close...'; read" >/dev/null 2>&1 &
    disown
    exit 0
fi
