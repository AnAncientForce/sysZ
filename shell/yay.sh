yay_packages=(
    vimix-gtk-themes
    vimix-cursors
    vimix-icon-theme
    betterlockscreen
    cava-git
    librewolf-bin
    picom-simpleanims-git
    autotiling
    ttf-font-awesome-4
)
not_installed=0
key="AUR"
echo "Checking $key"
for package in "${yay_packages[@]}"; do
    if ! yay -Qs "$package" >/dev/null; then
        yay -S --noconfirm "$package"
        not_installed=1
    fi
done

if [ $not_installed -eq 0 ]; then
    echo "$key packages are already installed"
fi
