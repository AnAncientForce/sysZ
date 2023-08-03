#!/bin/bash
# Anything that requires root perms will be here
# Anything that dose not require room perms will not be here

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

echo "Root setup has started"

read -p "
Install pacman packages & check for updates?
(y/n): " choice

if [ "$choice" = "y" ]; then
    sudo -u $SUDO_USER sh /home/$SUDO_USER/sysZ/shell/pacman.sh
fi

read -p "
Setup dark mode?
(y/n): " choice

if [ "$choice" = "y" ]; then
    echo "Setting up QT_QPA_PLATFORMTHEME in /etc/environment..."
    echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
fi

echo "Root setup has finished =D"
