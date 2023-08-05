#!/bin/bash

# Function to check if a window name contains a specific string
contains_window() {
    xprop -root | grep -q -i "$1"
}

# Function to check if mpv is running and playing an .mp4 video
is_mpv_playing() {
    pgrep -f "mpv.*\.mp4" &>/dev/null
}

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xdotool selectwindow >/dev/null 2>&1

    # Check if any window other than alacritty is in focus
    if ! contains_window "alacritty"; then
        if is_mpv_playing; then
            # Pause mpv if playing
            pkill -SIGSTOP mpv
        fi
    fi
done
