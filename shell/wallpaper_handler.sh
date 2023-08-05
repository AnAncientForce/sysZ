#!/bin/bash

# Function to check if a window has transparency
has_transparency() {
    local window_id="$1"
    local opacity=$(xprop -id "$window_id" | awk -F '=' '/_NET_WM_WINDOW_OPACITY\(CARDINAL\)/{print $2}')
    [[ "$opacity" -ne 4294967295 ]] # 4294967295 (0xFFFFFFFF) represents 1.0 opacity
}

# Function to send the pause command to mpv via socat
send_pause_command() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

# Wait for the mpv socket to be available
while [ ! -e /tmp/mpvsocket ]; do
    sleep 0.1
done

# Variable to store the playing state (0 for paused, 1 for playing)
is_playing=0

# Register a focus event listener
xdotool search --sync --onlyvisible --class "Alacritty" behave %@ focus &

# Main loop to monitor focus changes
while true; do
    # Wait for focus event
    window_id=$(xdotool search --sync --onlyvisible --class "Alacritty" behave %@ focus | tail -1)

    if has_transparency "$window_id"; then
        echo "Focused window has transparency."
        if [[ $is_playing -eq 1 ]]; then
            send_pause_command
            is_playing=0
        fi
    else
        echo "Focused window does not have transparency."
        if [[ $is_playing -eq 0 ]]; then
            send_pause_command
            is_playing=1
        fi
    fi
done
