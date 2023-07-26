#!/bin/bash

# List of pacman packages to install
pacman_packages=(
    kitty
    alacritty
    git
    thunar
    polybar
    rofi
    sox
    # Add more packages as needed
)

# List of yay packages to install
yay_packages=(
    picom-simpleanims-next-git
)

# Update package databases and upgrade system packages (optional but recommended)
sudo pacman -Syu --noconfirm

# Install pacman packages
sudo pacman -S --noconfirm "${pacman_packages[@]}"

# Install yay packages from AUR
yay -S --noconfirm "${yay_packages[@]}"
