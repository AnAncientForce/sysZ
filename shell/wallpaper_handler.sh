#!/bin/bash

# Function to check if alacritty is in focus
is_alacritty_focused() {
    xprop -root _NET_ACTIVE_WINDOW | grep -q "alacritty"
}

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused; then
        echo "Alacritty is in focus."
    else
        echo "Alacritty is not in focus."
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
