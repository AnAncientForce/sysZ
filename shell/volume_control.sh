#!/bin/bash

MAX_VOLUME=100

adjust_volume() {
    local sink_id=$(pactl list short sinks | awk '{print $1; exit}')
    local volume_percent=$(pactl list sinks | grep -A 10 "Sink #$sink_id" | grep 'Volume:' | awk '{print $5}' | sed 's/%//')

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

    pactl set-sink-volume "$sink_id" "$new_volume%" >/dev/null
    echo "$new_volume"
}

if [ "$1" = "up" ] || [ "$1" = "down" ]; then
    new_volume=$(adjust_volume "$1")
    echo "$new_volume"
    dunstify -t 2000 "Volume Adjusted" "$new_volume%"
fi
