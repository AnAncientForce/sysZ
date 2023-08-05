#!/bin/bash

# Function to check if mpv is running and playing an .mp4 video
is_mpv_playing() {
    pgrep -x "mpv" &>/dev/null && pgrep -f "\.mp4" &>/dev/null
}

# Function to pause the mpv video
pause_mpv() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xprop -root -spy | while read -r; do
        # Check if any window other than alacritty is in focus
        if ! xprop -root | grep -q -i "alacritty"; then
            if is_mpv_playing; then
                # Pause mpv if playing
                pause_mpv
            fi
        fi
    done
done
