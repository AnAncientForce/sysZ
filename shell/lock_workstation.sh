#!/bin/bash

if ! pgrep -x "i3lock" >/dev/null; then
    echo "i3lock is not running."
    exit 1
fi
