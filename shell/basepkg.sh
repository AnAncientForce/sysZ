#!/bin/bash

pacman_packages=(
    kitty
    alacritty
    git
    thunar
    gvfs
    polybar
    rofi
    sox
    feh
    ttf-font-awesome
    cava
    filelight
    neofetch
)


yay_packages=(
    librewolf
    picom-simpleanims-next-git
)

# Update package databases and upgrade system packages (optional but recommended)
# sudo pacman -Syu --noconfirm

# Check if pacman packages are installed and install missing ones
for package in "${pacman_packages[@]}"; do
    if ! pacman -Qs "$package" >/dev/null; then
        sudo pacman -S --noconfirm "$package"
    fi
done

# Check if yay packages are installed and install missing ones
for package in "${yay_packages[@]}"; do
    if ! yay -Qs "$package" >/dev/null; then
        yay -S --noconfirm "$package"
    fi
done