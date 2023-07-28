#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read the value from the JSON file
value=$(jq -r '.use_animations' "$script_dir/config.json")

# Check if the value is true
if [ "$value" = "true" ]; then
    i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    echo "picom_with_animations"
elif [ "$value" = "false" ]; then
    i3-msg 'exec picom -b --blur-background --corner-radius 4 --vsync;'
    echo "picom_without_animations"
fi

echo "refresh"
sh /home/$(whoami)/sysZ/shell/setup.sh
echo "refresh complete"
