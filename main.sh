restart() {
    killall -9 picom polybar
    i3-msg 'exec feh --bg-fill ~/sysZ/bg.*;'
    i3-msg 'exec polybar -c ~/sysZ/conf/polybar/config.ini;'
    i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    i3-msg "exec sox ~/sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
}

basepkg(){
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
)
yay_packages=(
    librewolf
    picom-simpleanims-next-git
)
# Update package databases and upgrade system packages (optional but recommended)
sudo pacman -Syu --noconfirm

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
}


cw(){
    cp "conf/i3/config" "/home/$(whoami)/.config/i3/"
    cp "conf/kitty/kitty.conf" "/home/$(whoami)/.config/kitty/"
    cp "conf/alacritty.yml" "/home/$(whoami)/.config/"
}