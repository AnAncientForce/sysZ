#!/bin/bash

# Function to check if alacritty is in focus
is_alacritty_focused() {
    xprop -root | grep -q -i "alacritty"
}

# Main loop to monitor focus changes
while true; do
    # Check if alacritty is in focus
    if is_alacritty_focused; then
        # Alacritty is in focus, resume live wallpaper
        echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
    else
        # Alacritty is not in focus, pause live wallpaper
        echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
