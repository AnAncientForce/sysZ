#!/bin/bash

# Listen for i3 window focus events using i3ipc-python
i3-msg -t subscribe -m '[{"change":"focus"}]' | while read -r event; do
    # Check if the focused window is alacritty
    if [[ $(echo "$event" | jq -r '.container.name') == "alacritty" ]]; then
        mpv --no-resume-playback
    else
        mpv --pause
    fi
done
