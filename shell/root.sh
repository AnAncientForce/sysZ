#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${BRed}[!] Must be running as sudo or root${Color_Off}"
    exit 1
fi
echo -e "${BRed}[*] Setting up QT_QPA_PLATFORMTHEME in /etc/environment...${Color_Off}"
echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
