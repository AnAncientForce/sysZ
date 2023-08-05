#!/bin/bash

while true; do
    xprop -root -spy | while read -r; do
        if ! xprop -root | grep -q -i "alacritty"; then
            if pgrep -x "mpv" &>/dev/null && pgrep -f "\.mp4" &>/dev/null; then
                echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
            fi
        fi
    done
done
