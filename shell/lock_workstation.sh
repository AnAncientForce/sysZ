#!/bin/bash
if pgrep -x "xss-lock" >/dev/null; then
    echo "Screen is locked."
else
    echo "Screen is not locked."
fi
