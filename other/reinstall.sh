#!/bin/bash

arch_packages_file="~/$USER/sysZ/recovery/packages.txt"
yay_packages_file="~/$USER/sysZ/recovery/yay.txt"

# Read and install regular Arch Linux packages
if [ -f "$arch_packages_file" ]; then
    while IFS= read -r package; do
        sudo pacman -S --noconfirm "$package"
    done < "$arch_packages_file"
else
    echo "Arch Linux packages file not found: $arch_packages_file"
fi

# Read and install yay packages
if [ -f "$yay_packages_file" ]; then
    while IFS= read -r package; do
        yay -S --noconfirm "$package"
    done < "$yay_packages_file"
else
    echo "yay packages file not found: $yay_packages_file"
fi
