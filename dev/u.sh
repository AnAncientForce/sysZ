#!/bin/bash
sysZ=""

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

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi
read -p "Delete pull.sh?" choice
if [ "$choice" = "y" ]; then
    rm -f "$sysZ/shell/pull.sh"
fi
repo_pull
chmod +x $sysZ/shell/pull.sh
cd $sysZ/shell
sh $sysZ/shell/pull.sh -u
