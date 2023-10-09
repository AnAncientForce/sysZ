#!/bin/bash

app1() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    [[ $active_window_name == "$(whoami)@$HOSTNAME:"* ]]
}

app2() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    [[ $active_window_name == *"Alacritty"* ]]
}

is_i3_focused() {
    local active_window_name=$(xdotool getwindowfocus getwindowname)
    [[ $active_window_name == *"i3"* ]]
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
