#!/usr/bin/env bash

timeout=120
if [ $# -eq 0 ]; then
    echo "[default timeout: 120]]"
else
    timeout=$1
fi

# Check if xidlehook is already running
if pgrep -f "xidlehook" >/dev/null; then
    echo "xidlehook is already running. Exiting."
    exit 1
fi

xidlehook --not-when-audio --timer $timeout 'sh ~/sysZ/shell/screensaver.sh &' ''
