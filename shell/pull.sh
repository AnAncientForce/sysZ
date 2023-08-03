#!/bin/bash
sysZ="/home/$(whoami)/sysZ"

# installable packages
pacman_packages=(
    "adobe-source-han-sans-jp-fonts"
    "adobe-source-han-sans-otc-fonts"
    "adobe-source-han-serif-otc-fonts"
    "alacritty"
    "ark"
    "brightnessctl"
    "calcurse"
    "feh"
    "filelight"
    "git"
    "gvfs"
    "kitty"
    "kvantum"
    "mpv-mpris"
    "neofetch"
    "pavucontrol"
    "polybar"
    "rofi"
    "sox"
    "thunar"
    "tldr"
    "wget"
    "zip"
    "python-pip"
    "tk"
    "lxappearance"
    "qt5ct"
    "jq"
    "python-pillow"
    "breeze"
    "base-devel"
    "git"
    "xfce4-screenshooter"
    "copyq"
    "plasma-systemmonitor"
    "ntfs-3g"
    "fuse"
    "thunar-volman"
)
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

# flag bools
automatic=false
run_as_root=false
update_check=false
install_pacman=false
install_yay=false
valid_flag=false

root_cmd() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "[!] - Run as sudo or as root"
        exit 1
    fi

    echo "Root setup has started"

    read -p "
    Install pacman packages & system update?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        sudo pacman -Syu
        sudo -u $SUDO_USER sh /home/$SUDO_USER/sysZ/shell/pacman.sh
    fi

    read -p "
    Setup QT_QPA_PLATFORMTHEME?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        echo "Setting up QT_QPA_PLATFORMTHEME in /etc/environment..."
        echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
    fi

    echo "Root setup has finished =D"
}

repo_pull() {
    # Store the current directory
    current_dir=$(pwd)

    # Change directory to sysZ root
    cd "$(dirname "$0")"

    # Check if it's a git repository before performing git pull
    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git pull origin main
        echo "Repository updated."
    else
        echo "Initializing a new git repository..."
        git init
        git remote add origin https://github.com/AnAncientForce/sysZ.git
        git fetch origin main
        git checkout -b main --track origin/main
        echo "Git repository set up. Repository is ready."
    fi
}

cu() {
    echo "Copying configuration files"
    mkdir -p "/home/$(whoami)/.config/kitty"
    cp "$sysZ/conf/i3" "/home/$(whoami)/.config/i3/config"
    cp "$sysZ/conf/kitty.conf" "/home/$(whoami)/.config/kitty"
    cp "$sysZ/conf/alacritty.yml" "/home/$(whoami)/.config"
}

ex() {
    echo "Making shell scripts executable"
    for file in "$sysZ/shell"/*.sh; do
        if [ -f "$file" ] && [ ! -x "$file" ]; then
            chmod +x "$file"
        fi
    done
}

manual() {
    echo "Manual update is starting"
    repo_pull

    # configuration files
    cu

    # make files executable
    ex

    # sysZ / config.json
    read -p "
    Copy default sysZ config file?
    " choice
    if [ "$choice" = "y" ]; then
        if [ -f "conf/config.json" ]; then
            mkdir -p "/home/$(whoami)/.config/sysZ/"
            cp "/home/$(whoami)/sysZ/conf/config.json" "/home/$(whoami)/.config/sysZ/"
            echo "sysZ config copied successfully"
        else
            echo "sysZ config file dose not exist"
        fi
    else
        echo "config.json was not replaced"
    fi

    echo "Scanning for changes in default applications"

    # install yay
    read -p "
    Install yay?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        if [ -d "yay" ]; then
            rm -rf "yay"
        fi
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yay --version
    fi

    # rofi
    read -p "
    [CAUTION]: rofi will not function correctly without this due to how the current configuration is setup
    Check if themes are installed? (if not, install them)
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        echo "Installing themes"
        cd
        git clone --depth=1 https://github.com/adi1090x/rofi.git
        cd rofi
        chmod +x setup.sh
        ./setup.sh
    else
        echo "CAUTION: super + d may not work/function correctly"
    fi

    # packages & update
    read -p "
    (y) Install yay packages
    (p) Install pacman packages
    (b) Install both packages
    (u) System Update
    " choice

    if [ "$choice" = "y" ]; then
        sh /home/$(whoami)/sysZ/shell/yay.sh
    elif [ "$choice" = "p" ]; then
        sh /home/$(whoami)/sysZ/shell/pacman.sh
    elif [ "$choice" = "b" ]; then
        sh /home/$(whoami)/sysZ/shell/yay.sh
        sh /home/$(whoami)/sysZ/shell/pacman.sh
    elif [ "$choice" = "u" ]; then
        sudo pacman -Syu
    else
        echo "Skipping..."
    fi

    # render lockscreen
    echo "Rendering lockscreen"
    betterlockscreen -u $sysZ/bg

    # end
    echo "===> All done! :)"
    cd "$current_dir"
}

check_updates() {
    current_dir=$(pwd)
    cd "/home/$(whoami)/sysZ"

    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git remote update >/dev/null 2>&1
        if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
            python /home/$(whoami)/sysZ/main.py update_confirmation
        else
            echo "No updates available."
        fi
    fi
}

# PACMAN & AUR INSTALL FUNCTIONS >

install_rec_pacman() {
    not_installed=0
    key="Arch"
    echo "Checking $key"
    for package in "${pacman_packages[@]}"; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            sudo pacman -S --noconfirm "$package"
            not_installed=1
        fi
    done
    if [ $not_installed -eq 1 ]; then
        echo "Some $key packages were installed."
    else
        echo "$key packages are already installed."
    fi
}

install_rec_yay() {
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
}

function trap_ctrlc() {
    echo "The update operation has been stopped."
    exit 2
}
trap "trap_ctrlc" 2

# ----------------------------- Flag Logic

for arg in "$@"; do
    case "$arg" in
    --automatic)
        automatic=true
        valid_flag=true
        ;;
    --root)
        run_as_root=true
        valid_flag=true
        ;;
    --pacman)
        install_pacman=true
        valid_flag=true
        ;;
    --yay)
        install_yay=true
        valid_flag=true
        ;;
    --update-check)
        update_check=true
        valid_flag=true
        ;;
    *)
        # Handle other arguments as needed
        ;;
    esac
done
if ! $valid_flag; then
    echo "Incorrect or misspelled flag"
    exit 1
fi

if [ "$automatic" = true ]; then
    repo_pull
    cu
    echo "Rendering lockscreen"
    betterlockscreen -u /home/$(whoami)/sysZ/bg
    cd "$current_dir"

elif [ "$run_as_root" = true ]; then
    root_cmd

elif [ "$update_check" = true ]; then
    check_updates

elif [ "$update_check" = true ]; then
    install_rec_pacman

elif [ "$update_check" = true ]; then
    install_rec_yay

else
    manual
fi
