#!/bin/bash

# Function to check if a window name contains a specific string
contains_window() {
    xprop -root | grep -q -i "$1"
}

# Check if the mpv process is running and playing an .mp4 video
is_mpv_playing() {
    pgrep -x "mpv" &>/dev/null && pgrep -f "\.mp4" &>/dev/null
}

# Pause the mpv player
pause_mpv() {
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.mpv /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause
}

# Play or resume the mpv player
play_mpv() {
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.mpv /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play
}

# Main loop to monitor focus changes
while true; do
    # Wait for the next focus event
    xdotool selectwindow >/dev/null 2>&1

    # Check if any window other than alacritty is in focus
    if ! xprop -root | grep -q -i "alacritty"; then
        if is_mpv_playing; then
            # Pause mpv if playing
            pause_mpv
        fi
    else
        if is_mpv_playing; then
            # Resume mpv if paused
            play_mpv
        fi
    fi
done
