#!/bin/bash

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xdotool selectwindow >/dev/null 2>&1

    # Check if any window other than alacritty is in focus
    if ! xprop -root | grep -q -i "alacritty"; then
        if pgrep -f "mpv.*\.mp4" &>/dev/null; then
            # Pause mpv if playing
            xdotool key --clearmodifiers "p"
        fi
    fi

    # Focus on alacritty or an empty workspace
    if xprop -root | grep -q -i "alacritty"; then
        xdotool search --name "Alacritty" windowactivate
    else
        xdotool key --clearmodifiers "Super+1" # Replace with your workspace switching keybinding
    fi
done
