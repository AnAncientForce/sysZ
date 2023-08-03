#!/bin/bash

pacman_packages=(
    "adobe-source-han-sans-jp-fonts"
    "adobe-source-han-sans-otc-fonts"
    "adobe-source-han-serif-otc-fonts"
    "alacritty"
    "ark"
    "brightnessctl"
    "calcurse"
    "feh"
    "filelight"
    "git"
    "gvfs"
    "kitty"
    "kvantum"
    "mpv-mpris"
    "neofetch"
    "pavucontrol"
    "polybar"
    "rofi"
    "sox"
    "thunar"
    "tldr"
    "wget"
    "zip"
    "python-pip"
    "tk"
    "lxappearance"
    "qt5ct"
    "jq"
    "python-pillow"
    "breeze"
    "base-devel"
    "git"
    "xfce4-screenshooter"
    "copyq"
    "plasma-systemmonitor"
)

# ttf-font-awesome, ranger, playerctl, piper, obsidian, intel-ucode
not_installed=0

key="Arch"
echo "Checking $key"
for package in "${pacman_packages[@]}"; do
    if ! pacman -Qi "$package" >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$package"
        not_installed=1
    fi
done

if [ $not_installed -eq 1 ]; then
    echo "Some $key packages were installed."
else
    echo "$key packages are already installed."
fi
