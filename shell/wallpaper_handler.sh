#!/bin/bash

# Function to check if a window name contains a specific string
contains_window() {
    xprop -root | grep -q -i "$1"
}

# Command to set the live wallpaper
LIVE_WALLPAPER_COMMAND="xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv -wid WID --loop --no-audio $sysZ/vid.mp4"

# Main loop
while true; do
    # Get the currently focused window name
    FOCUSED_WINDOW=$(xdotool getwindowfocus getwindowname)

    # Check if the terminal (alacritty) is in focus
    if contains_window "alacritty"; then
        # Terminal is in focus, allow the wallpaper to play
        if ! pgrep -f "mpv" &>/dev/null; then
            # Start the live wallpaper if it's not already running
            # $LIVE_WALLPAPER_COMMAND &
        fi
    else
        # Terminal is not in focus, pause the wallpaper if it's running
        pkill -SIGSTOP mpv
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
