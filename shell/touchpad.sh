#!/bin/bash

user_home=""
sysZ=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    user_home="/home/$(whoami)"
fi

# https://wiki.archlinux.org/title/Touchpad_Synaptics

read -p "y = install, n = uninstall (y/n): " choice

if [ "$choice" = "y" ]; then
    # sudo cp "$sysZ/conf/30-touchpad.conf" "/etc/X11/xorg.conf.d/30-touchpad.conf"
    sudo cp "$sysZ/conf/70-synaptics.conf" "/etc/X11/xorg.conf.d/70-synaptics.conf"
    echo "Installed"
elif [ "$choice" = "n" ]; then
    # sudo rm "/etc/X11/xorg.conf.d/30-touchpad.conf"
    sudo rm "/etc/X11/xorg.conf.d/70-synaptics.conf"
    echo "Removed"
else
    echo "Invalid choice. Please enter 'y' to install or 'n' to uninstall."
fi

exit 0
