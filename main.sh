#!/bin/bash
picom_without_animations() {
    i3-msg 'exec picom -b --blur-background --corner-radius 4 --vsync;'
    echo "picom_without_animations"
}
picom_with_animations() {
    i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    echo "picom_with_animations"
}
setup() {
    sh /home/$(whoami)/sysZ/shell/setup.sh
}
"$@"
