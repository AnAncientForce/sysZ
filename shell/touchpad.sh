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

read -p "y = install, n = uninstall (y/n): " choice

if [ "$choice" = "y" ]; then
    sudo cp "$sysZ/conf/70-synaptics.conf" "/usr/share/X11/xorg.conf.d/70-synaptics.conf"
    echo "Installed"
elif [ "$choice" = "n" ]; then
    sudo rm "/usr/share/X11/xorg.conf.d/70-synaptics.conf"
    echo "Removed"
else
    echo "Invalid choice. Please enter 'y' to install or 'n' to uninstall."
fi

exit 0
