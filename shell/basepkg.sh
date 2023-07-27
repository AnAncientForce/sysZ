#!/bin/bash

pacman_packages=(
adobe-source-han-sans-jp-fonts
adobe-source-han-sans-otc-fonts
adobe-source-han-serif-otc-fonts
alacritty
ark
brightnessctl
calcurse
feh
filelight
git
gvfs
intel-ucode
kitty
kvantum
lxappearance
mpv-mpris
neofetch
obsidian
pavucontrol
piper
playerctl
polybar
ranger
rofi
sox
thunar
tldr
ttf-font-awesome
wget
zip
python-pip
tk
lxapperance
)
# HEAVY: arduino, gimp

yay_packages=(
    vimix-gtk-themes
    vimix-cursors
    vimix-icon-theme
    cava-git
    librewolf-bin
    picom-simpleanims-next-git
)
# https://archlinux.org/packages/
# https://aur.archlinux.org/

# Update package databases and upgrade system packages (optional but recommended)
# sudo pacman -Syu --noconfirm



# Run specific function is specified
if [ "$1" == "--function" ]; then
    shift  # Shift the arguments to skip the "--function" flag
    function_name="$1"
    shift  # Shift again to skip the function name

    # Call the specified function
    "$function_name"
fi


install_missing_packages() {
    local package_manager=$1
    local packages=()

    if [ "$package_manager" = "pacman" ]; then
        packages=("${pacman_packages[@]}")
    elif [ "$package_manager" = "yay" ]; then
        packages=("${yay_packages[@]}")
    else
        echo "Invalid package manager specified."
        return 1
    fi

    for package in "${packages[@]}"; do
        if ! "$package_manager" -Qs "$package" >/dev/null; then
            sudo "$package_manager" -S --noconfirm "$package"
        fi
    done
}

ro(){
    install_missing_packages "pacman"
}
wo(){
    install_missing_packages "yay"
}

#install_missing_packages "pacman"
#install_missing_packages "yay"

