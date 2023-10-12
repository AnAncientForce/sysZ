#!/bin/bash

while true; do

    cpu_temp=$(sensors | grep "Core 0" | awk '{print $3}' | cut -c 2-3)

    echo "$cpu_temp"

    if [ "$cpu_temp" -ge 60 ]; then
        echo "Warning"
    fi

    sleep 2
done
