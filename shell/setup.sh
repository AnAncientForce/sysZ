#!/bin/bash

# Execute splash.py in the background
python ~/sysZ/splash.py load &

# Store the process ID (PID) of splash.py
splash_pid=$!

# Execute the remaining commands
killall -9 picom polybar
i3-msg 'exec feh --bg-fill ~/sysZ/bg.*;'
i3-msg 'exec polybar -c ~/sysZ/conf/polybar/config.ini;'
i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
i3-msg "exec sox ~/sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
i3-msg "reload"

# Wait for splash.py to finish
wait $splash_pid




# polybar -c ~/.config/polybar/config.ini
# picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 10 --config ~/.config/picom/conf --vsync
