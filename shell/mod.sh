#!/bin/bash

Color_Off='\033[0m'
BBlack='\033[1;30m' BRed='\033[1;31m' BGreen='\033[1;32m' BYellow='\033[1;33m'
BBlue='\033[1;34m' BPurple='\033[1;35m' BCyan='\033[1;36m' BWhite='\033[1;37m'

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
# https://archlinux.org/pacman/pacman.conf.5.html

mkdir -p "$user_home/.config/emergency-restore"

read -p "t = touchpad, p = pacman (t/p): " choice

if [ "$choice" = "t" ]; then
    read -p "y = install, n = uninstall (y/n): " choice
    sudo cp "/etc/X11/xorg.conf.d/70-synaptics.conf" "$user_home/.config/emergency-restore/70-synaptics.conf"

    if [ "$choice" = "y" ]; then
        # sudo cp "$sysZ/conf/30-touchpad.conf" "/etc/X11/xorg.conf.d/30-touchpad.conf"
        sudo cp "$sysZ/conf/70-synaptics.conf" "/etc/X11/xorg.conf.d/70-synaptics.conf"
        echo -e "${BGreen}[*] Installed\n${Color_Off}"
    elif [ "$choice" = "n" ]; then
        # sudo rm "/etc/X11/xorg.conf.d/30-touchpad.conf"
        sudo rm "/etc/X11/xorg.conf.d/70-synaptics.conf"
        echo -e "${BGreen}[*] Removed\n${Color_Off}"
    else
        echo -e "${BRed}[*] Invalid choice. Please enter 'y' to install or 'n' to uninstall.\n${Color_Off}"
    fi
elif [ "$choice" = "p" ]; then
    sudo cp "/etc/pacman.conf" "$user_home/.config/emergency-restore/pacman.conf"
    sudo cp "$sysZ/conf/pacman.conf" "/etc/pacman.conf"
    echo -e "${BGreen}[*] Installed\n${Color_Off}"
else
    echo -e "${BRed}[*] Invalid choice\n${Color_Off}"
fi

exit 0
