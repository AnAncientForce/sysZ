#!/bin/bash

# List of example packages to install
packages=(
    kitty
    alacritty
    git
    thunar
    polybar
    rofi
    # Add more packages as needed
)

# Update package database and upgrade system packages (optional but recommended)
sudo pacman -Syu --noconfirm

# Install the specified packages
sudo pacman -S --noconfirm "${packages[@]}"
