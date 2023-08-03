#!/bin/bash

echo "Root setup has started"

read -p "
Install pacman packages & check for updates?
(y/n): " choice

if [ "$choice" = "y" ]; then
    sh /home/$(whoami)/sysZ/shell/pacman.sh
fi

read -p "
Setup dark mode?
(y/n): " choice

if [ "$choice" = "y" ]; then
    echo "Setting up QT_QPA_PLATFORMTHEME in /etc/environment..."
    echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
fi

echo "Root setup has finished =D"
