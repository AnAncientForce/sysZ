yay_packages=(
    vimix-gtk-themes
    vimix-cursors
    vimix-icon-theme
    betterlockscreen
    cava-git
    librewolf-bin
    picom-simpleanims-git
    autotiling
)
not_installed=0

echo "Checking AUR"
for package in "${yay_packages[@]}"; do
    if ! yay -Qs "$package" >/dev/null; then
        yay -S --noconfirm "$package"
        not_installed=1
    fi
done

if [ $not_installed -eq 0 ]; then
    echo "All packages are already installed"
fi
