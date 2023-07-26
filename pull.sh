#!/bin/bash

# Store the current directory
current_dir=$(pwd)

# Change directory to sysZ root
cd "$(dirname "$0")"

# Check if it's a git repository before performing git pull
if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git pull
    echo "Repository updated."
else
    echo "Not a git repository. Initializing a new git repository..."
    git init
    git remote add origin https://github.com/AnAncientForce/sysZ.git
    git fetch
    git checkout main
fi

# Return to the original directory
cd "$current_dir"
