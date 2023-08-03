#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] - Run as sudo or as root"
    exit 1
fi

echo "Root setup has started"

read -p "
Install pacman packages & system update?
(y/n): " choice

if [ "$choice" = "y" ]; then
    sudo pacman -Syu
    sudo -u $SUDO_USER sh /home/$SUDO_USER/sysZ/shell/pacman.sh
fi

read -p "
Setup QT_QPA_PLATFORMTHEME?
(y/n): " choice

if [ "$choice" = "y" ]; then
    echo "Setting up QT_QPA_PLATFORMTHEME in /etc/environment..."
    echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
fi

echo "Root setup has finished =D"
