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

# Function to send the play command to mpv via socat
send_play_command() {
    echo '{"command": ["cycle", "play"]}' | socat - /tmp/mpvsocket
}

# Wait for the mpv socket to be available
while [ ! -e /tmp/mpvsocket ]; do
    sleep 0.1
done

# Variable to store the last focused window name
last_window_name=$(xdotool getwindowfocus getwindowname)

# Main loop to monitor focus changes
while true; do
    current_window_name=$(xdotool getwindowfocus getwindowname)

    if [[ $current_window_name != $last_window_name ]]; then
        if is_alacritty_or_i3_focused; then
            echo "Alacritty or i3 is in focus."
            send_play_command
        else
            echo "Alacritty and i3 are not in focus."
            send_pause_command
        fi

        last_window_name=$current_window_name
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
