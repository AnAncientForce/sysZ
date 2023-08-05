#!/bin/bash

# Variable to store the playing state (0 for paused, 1 for playing)
is_playing=0

is_alacritty_focused() {
    local active_window_title=$(xprop -id "$(xdotool getactivewindow)" WM_NAME | sed -r 's/WM_NAME\(\w+\) = "(.*)"$/\1/')
    [[ $active_window_title == "$(whoami)@$HOSTNAME:"* ]]
}

send_pause_command() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

sleep 2
while true; do
    if is_alacritty_focused; then
        echo "Good"
        if [[ $is_playing -eq 0 ]]; then
            send_pause_command
            is_playing=1
        fi
    else
        echo "Bad"
        if [[ $is_playing -eq 1 ]]; then
            send_pause_command
            is_playing=0
        fi
    fi
    sleep 0.5
done
