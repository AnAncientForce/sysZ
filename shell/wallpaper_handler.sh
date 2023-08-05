#!/bin/bash
PLAY=false
while true; do
    if [ "$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ $PLAY == false ]; then
        echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
        PLAY=true
    elif [ "$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ $PLAY == true ]; then
        echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
        PLAY=false
    fi
    sleep 1
done
