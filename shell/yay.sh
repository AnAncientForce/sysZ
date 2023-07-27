yay_packages=(
    vimix-gtk-themes
    vimix-cursors
    vimix-icon-theme
    betterlockscreen
    cava-git
    librewolf-bin
    picom-simpleanims-next-git
)
for package in "${yay_packages[@]}"; do
        if ! yay -Qs "$package" >/dev/null; then
            yay -S --noconfirm "$package"
        fi
done