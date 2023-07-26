#!/bin/bash
killall -9 picom polybar
i3-msg 'exec feh --bg-fill ~/sysZ/bg.*;'
i3-msg 'exec polybar -c ~/sysZ/conf/polybar/config.ini;'
i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
i3-msg "exec sox ~/sysZ/sfx/Sys_Camera_SavePicture.flac -d;"

# polybar -c ~/.config/polybar/config.ini
# picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 10 --config ~/.config/picom/conf --vsync
