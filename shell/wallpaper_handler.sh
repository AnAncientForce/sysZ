#!/bin/bash

is_mpv_playing() {
    pgrep -x "mpv" &>/dev/null && pgrep -f "\.mp4" &>/dev/null
}

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xdotool selectwindow >/dev/null 2>&1

    # Check if any window other than alacritty is in focus
    if ! xprop -root | grep -q -i "alacritty"; then
        if is_mpv_playing; then
            echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
        fi
    fi
done
