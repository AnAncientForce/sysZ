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
sh main.sh cu

echo "Scanning for changes in default applications"
read -p "Check if the recommended applications are installed? (And if not, automatically install them) (y/n): " choice
if [ "$choice" = "y" ]; then
    sh main.sh basepkg.
fi

echo "Rendering lockscreen"
betterlockscreen ~/sysZ/bg.png

echo "Restarting shell"
sh main.sh setup
echo "===> All done! :)"

# Return to the original directory
cd "$current_dir"
