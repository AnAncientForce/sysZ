#!/bin/bash
killall -9 picom polybar
i3-msg 'exec feh --bg-fill ~/sysZ/bg.*;'
i3-msg 'exec polybar -c ~/sysZ/conf/polybar.ini;'
i3-msg 'exec picom -b --blur-background --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
i3-msg "exec sox ~/sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
i3-msg "reload"
# i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
# polybar -c ~/.config/polybar/config.ini
# picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 10 --config ~/.config/picom/conf --vsync
