#!/bin/bash

# Function to check if a window name contains a specific string
contains_window() {
    xprop -root | grep -q -i "$1"
}

# Set initial state (not in focus)
WINDOW_IN_FOCUS=false

# Get the window ID of the live wallpaper window
LIVE_WALLPAPER_WINDOW_ID=$(wmctrl -l | grep "MPV MEDIA PLAYER" | cut -f 1 -d " ")

# Function to show or hide the live wallpaper based on focus state
toggle_live_wallpaper() {
    if $WINDOW_IN_FOCUS; then
        # Terminal is in focus, show the live wallpaper window
        wmctrl -i -r $LIVE_WALLPAPER_WINDOW_ID -b remove,hidden
    else
        # Terminal is not in focus, hide the live wallpaper window
        wmctrl -i -r $LIVE_WALLPAPER_WINDOW_ID -b add,hidden
    fi
}

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xdotool selectwindow >/dev/null 2>&1

    # Check if the terminal (alacritty) is in focus
    if contains_window "alacritty"; then
        WINDOW_IN_FOCUS=true
    else
        WINDOW_IN_FOCUS=false
    fi

    # Show or hide the live wallpaper based on the focus state
    toggle_live_wallpaper
done
