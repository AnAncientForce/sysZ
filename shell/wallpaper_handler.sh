#!/bin/bash

user_home=""
sysZ=""
temp_dir=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    user_home="/home/$(whoami)"
fi
temp_dir="$user_home/tmp"
lockfile="$temp_dir/live_wallpaper_state.lock"

#

xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv --input-ipc-server=/tmp/mpvsocket -wid WID --loop --no-audio "$live_wallpaper_path"
mpv_pid=$!

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
    if is_window_focused; then
        echo "in focus"
        playerctl -p mpv status | grep -q "Playing"
        if [[ $? -ne 0 ]]; then
            send_pause_command
            touch "$lockfile"
            echo "playing" >"$lockfile"
        fi
    else
        echo "not in focus"
        playerctl -p mpv status | grep -q "Paused"
        if [[ $? -ne 0 ]]; then
            send_pause_command
            touch "$lockfile"
            echo "paused" >"$lockfile"
        fi
    fi
    cpu_temp=$(sensors | grep "Core 0" | awk '{print $3}' | cut -c 2-3)
    if [ "$cpu_temp" -ge 85 ]; then
        echo "Temperature is dangerously high, so the LIVE_WALLPAPER was stopped." >>"${sysZ}/log.txt"
        cleanup
    fi
    sleep 5
done

cleanup() {
    rm -f "$lockfile"
    if [ -n "$mpv_pid" ]; then
        kill "$mpv_pid"
    fi
    exit 0
}
trap cleanup EXIT
