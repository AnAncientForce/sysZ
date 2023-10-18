#!/bin/bash

user_home=""
json_file=""
sysZ=""
temp_dir=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    json_file="/home/$SUDO_USER/.config/sysZ/config.json"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    json_file="/home/$(whoami)/.config/sysZ/config.json"
    user_home="/home/$(whoami)"
fi
source "$sysZ/shell/common.sh"
temp_dir="$user_home/tmp"
lockfile="$temp_dir/live_wallpaper_state.lock"
ipc_socket="/tmp/mpvsocket"
live_wallpaper_path=$(checkJsonString "live_wallpaper_path")

rm -f "$lockfile"
xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv --input-ipc-server=/tmp/mpvsocket -wid WID --loop --no-audio "$live_wallpaper_path"
xwinwrap_pid=$!

cleanup() {
    rm -f "$lockfile"
    if [ -n "$xwinwrap_pid" ]; then
        kill "$xwinwrap_pid"
    fi
    pkill -f "xwinwrap"
    pkill -f "mpv --input-ipc-server=$ipc_socket"
    rm -f "$ipc_socket"
    exit 0
}
#

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

    if [ -f "$lockfile" ]; then
        lockfile_content=$(<"$lockfile")
        if ! [ "$lockfile_content" != "suspended" ]; then
            # Proceed if not in 'suspended' state

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
                echo "Temperature is dangerously high." >>"${sysZ}/log.txt"
                if [ -f "$lockfile" ]; then
                    lockfile_content=$(<"$lockfile")
                    if ! [ "$lockfile_content" == "playing" ]; then
                        # suspend live wallpaper
                        echo "The LIVE_WALLPAPER was paused and cannot resume until system has reached a safe temperature." >>"${sysZ}/log.txt"
                        send_pause_command
                        touch "$lockfile"
                        echo "suspended" >"$lockfile"
                    fi
                fi

                # cleanup
            fi
        fi
    fi
    sleep 5

done

trap cleanup EXIT
