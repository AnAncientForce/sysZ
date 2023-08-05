#!/bin/bash

# Function to check if alacritty is in focus and the window title matches "username@hostname"
is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused; then
        echo "Alacritty is in focus and has the correct window title."
        echo '{"command": ["cycle", "play"]}' | socat - /tmp/mpvsocket
    else
        echo "Alacritty is not in focus or has an incorrect window title."
        echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
