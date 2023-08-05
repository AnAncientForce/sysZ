#!/bin/bash
WID=$(xdotool search --name "mpv" | head -n 1)

i3-msg -t subscribe -m '[{"change":"focus"}]' | while read -r event; do
    if [[ $(echo "$event" | jq -r '.container.name') == "alacritty" ]]; then
        xwinwrap -id "$WID" -unpause
    else
        xwinwrap -id "$WID" -pause
    fi
done
