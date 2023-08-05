#!/bin/bash

# Function to check if a window name contains a specific string
contains_window() {
    xprop -root | grep -q -i "$1"
}

# Function to check if mpv is running
is_mpv_running() {
    pgrep -f "mpv" &>/dev/null
}

# Set initial state (not in focus)
WINDOW_IN_FOCUS=false

# Function to pause or resume the live wallpaper based on focus state
toggle_live_wallpaper() {
    if $WINDOW_IN_FOCUS; then
        # Terminal is in focus, allow the wallpaper to play
        if ! is_mpv_running; then
            # Resume the live wallpaper if it was paused
            pkill -SIGCONT mpv
        fi
    else
        # Terminal is not in focus, pause the wallpaper if it's running
        if is_mpv_running; then
            pkill -SIGSTOP mpv
        fi
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

    # Pause or resume the live wallpaper based on the focus state
    toggle_live_wallpaper
done
