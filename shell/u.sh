#!/bin/bash
sysZ=""
if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi
rm -f "$sysZ/shell/pull.sh"

# Store the current directory
current_dir=$(pwd)

# Change directory to sysZ root
cd "$(dirname "$0")"

# Check if it's a git repository and perform git pull or initialize a new git repository
if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git pull origin main
    echo "Repository updated."
else
    echo "Initializing a new git repository..."
    git clone --branch main https://github.com/AnAncientForce/sysZ.git .
    echo "Git repository set up. Repository is ready."
fi

chmod +x $sysZ/pull.sh
cd $sysZ/shell
