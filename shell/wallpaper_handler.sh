#!/bin/bash

window_names=("$(whoami)@$HOSTNAME:" "Alacritty" "i3")

is_window_focused() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    for name in "${window_names[@]}"; do
        if [[ $active_window_name == *"$name"* ]]; then
            return 0 # Window name matched
        fi
    done
    return 1 # Window name didn't match any
}

send_pause_command() {
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
}

while [ ! -e /tmp/mpvsocket ]; do
    sleep 0.1
done

while true; do
    if app1 || app2 || is_i3_focused; then
        echo "in focus"
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    else
        echo "not in focus"
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
        fi
    fi
    sleep 2.5
done
