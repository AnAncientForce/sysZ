#!/bin/bash
sysZ="/home/$(whoami)/sysZ"

repo_pull() {
    # Store the current directory
    current_dir=$(pwd)

    # Change directory to sysZ root
    cd "$(dirname "$0")"

    # Check if it's a git repository before performing git pull
    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git reset --hard origin/main
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

# Automatic
repo_pull
cu
echo "Rendering lockscreen"
betterlockscreen -u /home/$(whoami)/sysZ/bg
cd "$current_dir"
