#!/bin/bash

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
sh shell/cu.sh

echo "Scanning for changes in default applications"

read -p "(b) Install recommended applications if not already installed\n
(u) Check for system update\n
(n) Do neither\n
(b/u/n): " choice

if [ "$choice" = "b" ]; then
    sh shell/basepkg.sh
elif [ "$choice" = "u" ]; then
    sudo pacman -Syu
fi

echo "Rendering lockscreen"
betterlockscreen ~/sysZ/bg.png

echo "Restarting shell"
sh shell/setup.sh
echo "===> All done! :)"

# Return to the original directory
cd "$current_dir"