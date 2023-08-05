#!/bin/bash

# Variable to store the playing state (0 for paused, 1 for playing)
is_playing=0

# Function to check if alacritty is in focus and the window title matches "username@hostname"
is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

# Function to send the pause command to mpv via socat
send_pause_command() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

# Wait for the mpv socket to be available
while [ ! -e /tmp/mpvsocket ]; do
    sleep 0.1
done

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused; then
        echo "Alacritty is in focus."
        if [[ $is_playing -eq 0 ]]; then
            send_pause_command
            is_playing=1
        fi
    else
        echo "Alacritty is not in focus."
        if [[ $is_playing -eq 1 ]]; then
            send_pause_command
            is_playing=0
        fi
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
