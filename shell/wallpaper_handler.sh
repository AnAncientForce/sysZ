#!/bin/bash

# Function to check if alacritty or i3 is in focus
is_alacritty_or_i3_focused() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    if [[ $active_window_name == "$(whoami)@$HOSTNAME:"* || $active_window_name == "i3" ]]; then
        return 0
    else
        return 1
    fi
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
    if is_alacritty_or_i3_focused; then
        echo "Alacritty or i3 is in focus."
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    else
        echo "Alacritty and i3 are not in focus."
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    fi

    # Small sleep to reduce CPU usage
    sleep 5
done
