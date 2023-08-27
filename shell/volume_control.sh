#!/bin/bash

MAX_VOLUME=100

adjust_volume() {
    volume_percent=$(amixer -D pulse sget Master | grep 'Right:' | awk -F'[][]' '{print $2}')

    if [ "$1" = "up" ]; then
        new_volume=$((volume_percent + 10))
    elif [ "$1" = "down" ]; then
        new_volume=$((volume_percent - 10))
    fi

    if [ "$new_volume" -gt "$MAX_VOLUME" ]; then
        new_volume=$MAX_VOLUME
    elif [ "$new_volume" -lt "0" ]; then
        new_volume=0
    fi

    amixer -D pulse sset Master "$new_volume"% >/dev/null
    echo "$new_volume"
}

if [ "$1" = "up" ] || [ "$1" = "down" ]; then
    new_volume=$(adjust_volume "$1")
    echo "Volume: $new_volume%"
fi
