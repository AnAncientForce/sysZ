#!/bin/bash

# Function to check if alacritty is in focus and the window title matches "username@hostname"
is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

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

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused; then
        echo "Alacritty is in focus."
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    else
        echo "Alacritty is not in focus."
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    fi

    # Check for transparency
    focused_window_id=$(xdotool getactivewindow)
    if has_transparency "$focused_window_id"; then
        echo "Focused window has transparency."
        send_pause_command
    fi

    # Small sleep to reduce CPU usage
    sleep 0.5
done
