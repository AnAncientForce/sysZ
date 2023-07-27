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
    lxappearance
    qt5ct
)
not_installed=0

for package in "${pacman_packages[@]}"; do
    if ! pacman -Qs "$package" >/dev/null; then
        sudo pacman -S --noconfirm "$package"
        not_installed=1
    fi
done

if [ $not_installed -eq 0 ]; then
    echo "All packages are already installed"
fi
