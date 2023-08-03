#!/bin/bash
sysZ="/home/$(whoami)/sysZ"

killall -9 polybar
#feh --bg-fill /home/$(whoami)/sysZ/bg.*
#polybar -c "$sysZ/conf/polybar.ini" >/dev/null 2>&1 &
#sh "$sysZ/shell/background_update_check.sh" & # & Because if there is an update, the setup screen will never go away
#sox "$sysZ/sfx/Sys_Camera_SavePicture.flac" -d >/dev/null 2>&1 &

# bg.*
i3-msg "exec feh --bg-fill $sysZ/bg;"
i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"
i3-msg "exec sh $sysZ/shell/background_update_check.sh;"
i3-msg "exec sox $sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
i3-msg "reload"

# & DOSE NOT HOLD UP SHELL
# >/dev/null 2>&1 & REDIRECTS OUTPUT TO NULL

# i3-msg 'exec feh --bg-fill ~/sysZ/bg.*;' &
# i3-msg 'exec polybar -c ~/sysZ/conf/polybar.ini;' &
# i3-msg "exec sh /home/$(whoami)/sysZ/shell/background_update_check.sh;" &
# i3-msg "exec sox ~/sysZ/sfx/Sys_Camera_SavePicture.flac -d;"

# i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
# i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
# polybar -c ~/.config/polybar/config.ini
# picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 10 --config ~/.config/picom/conf --vsync

#.......
