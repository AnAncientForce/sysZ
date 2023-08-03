#!/bin/bash

yay_packages=(
    "vimix-gtk-themes"
    "vimix-cursors"
    "vimix-icon-theme"
    "cava-git"
    "librewolf-bin"
    "picom-simpleanims-git"
    "autotiling"
    "ttf-font-awesome-4"
)
# betterlockscreen must be installed manually

not_installed=0
key="AUR"
echo "Checking $key"
for package in "${yay_packages[@]}"; do
    if ! yay -Qs "$package" >/dev/null; then
        yay -S --noconfirm "$package"
        not_installed=1
    fi
done

if [ $not_installed -eq 1 ]; then
    echo "Some $key packages were installed."
else
    echo "$key packages are already installed."
fi
