#!/bin/bash
sysZ="/home/$(whoami)/sysZ"
killall -9 polybar copyq
i3-msg "exec feh --bg-fill $sysZ/bg;"
i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"
i3-msg "exec sh $sysZ/shell/background_update_check.sh;"
i3-msg "exec copyq;"
i3-msg "exec sox $sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
i3-msg "reload"
