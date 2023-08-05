#!/bin/bash

# Function to check if alacritty is in focus and the window title matches "username@hostname"
is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

# Function to check if "i3" is in the window name
is_i3_focused() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    [[ $active_window_name == *"i3"* ]]
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

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused || is_i3_focused; then
        echo "Alacritty or i3 is in focus."
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_play_command
        fi
    else
        echo "Alacritty and i3 are not in focus."
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
