#!/bin/bash

# Function to check if alacritty is in focus and the window title matches "username@hostname"
is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

# Function to send the pause command to mpv via socat
send_pause_command() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

# Function to check if there are any windows in the current workspace
has_windows_in_workspace() {
    local active_window_id=$(xdotool getactivewindow)
    local current_workspace=$(xprop -id "$active_window_id" _NET_WM_DESKTOP | awk '{print $2}')
    local windows_in_workspace=$(xdotool search --onlyvisible --desktop "$current_workspace" "" 2>/dev/null)
    [[ -n "$windows_in_workspace" ]]
}

# Wait for the mpv socket to be available
while [ ! -e /tmp/mpvsocket ]; do
    sleep 0.1
done

# Main loop to monitor focus changes
while true; do
    if is_alacritty_focused || has_windows_in_workspace; then
        echo "Alacritty is in focus or there are windows in the workspace."
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    else
        echo "Alacritty is not in focus and there are no windows in the workspace."
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    fi

    # Small sleep to reduce CPU usage
    sleep 5
done
