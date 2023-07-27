#!/bin/bash

cw(){
    cp "conf/i3/config" "/home/$(whoami)/.config/i3/"
    cp "conf/kitty/kitty.conf" "/home/$(whoami)/.config/kitty/"
    cp "conf/alacritty.yml" "/home/$(whoami)/.config/"
}

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

echo "Updating configuration files"
cw

echo "Scanning for changes in default applications"

read -p "
(i) Install recommended applications (if not already installed)
(c) Check for system update
(s) Skip
(i/c/s): " choice

if [ "$choice" = "b" ] || [ "$choice" = "u" ] || [ "$choice" = "n" ]; then
    if [ "$choice" = "b" ]; then
        sh shell/basepkg.sh
    elif [ "$choice" = "u" ]; then
        sudo pacman -Syu
    elif [ "$choice" = "s" ]; then
        echo "Skipping..."
    fi
else
    echo "Skipping..."
fi
echo "Rendering lockscreen"
betterlockscreen ~/sysZ/bg.png


echo "Checking python setup..."
pip install -r requirements.txt

echo "Restarting shell"
sh shell/setup.sh
echo "===> All done! :)"

# Return to the original directory
cd "$current_dir"