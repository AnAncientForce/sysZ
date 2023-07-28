#!/bin/bash

cu() {
    echo "Copying new files..."
    cp "/home/$(whoami)/sysZ/conf/i3" "/home/$(whoami)/.config/i3/config"
    cp "/home/$(whoami)/sysZ/conf/kitty.conf" "/home/$(whoami)/.config/kitty/"
    cp "/home/$(whoami)/sysZ/conf/alacritty.yml" "/home/$(whoami)/.config/"
}

themes_setup() {
    echo "Installing themes"
    cd
    git clone --depth=1 https://github.com/adi1090x/rofi.git
    cd rofi
    chmod +x setup.sh
    ./setup.sh
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

# Anything that requires sudo should not be included in this script
repo_pull
cu
# sh shell/yay.sh
betterlockscreen ~/sysZ/bg.png
themes_setup
cd "$current_dir"
i3-msg 'exec sh ~/sysZ/main.sh;'
