#!/bin/bash

# Read the value from the JSON file
value=$(jq -r '.use_animations' "config.json")

# Check if the value is true
if [ "$value" = "true" ]; then
    i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    echo "picom_with_animations"
else
    i3-msg 'exec picom -b --blur-background --corner-radius 4 --vsync;'
    echo "picom_without_animations"
fi
