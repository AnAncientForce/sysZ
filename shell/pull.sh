#!/bin/bash
sysZ="/home/$(whoami)/sysZ"
automatic=false
run_as_root=false

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

# ----------------------------- Flag Logic

for arg in "$@"; do
    case "$arg" in
    --automatic)
        automatic=true
        ;;
    --root)
        run_as_root=true
        ;;
    *)
        # Handle other arguments as needed
        ;;
    esac
done

if [ "$automatic" = true ]; then
    repo_pull
    cu
    echo "Rendering lockscreen"
    betterlockscreen -u /home/$(whoami)/sysZ/bg
    cd "$current_dir"

else
    manual
fi

if [ "$run_as_root" = true ]; then
    root_cmd
fi
