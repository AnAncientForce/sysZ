#!/bin/bash

# Set the repository URL and folder name
repo_url="https://github.com/AnAncientForce/sysZ.git"
folder_name="sysZ"

# Check if the folder exists; if not, clone the repository
if [ ! -d "$folder_name" ]; then
    git clone "$repo_url" "$folder_name"
    echo "Repository cloned to $folder_name"
else
    # If the folder exists, go into it and update the repository
    cd "$folder_name"
    git pull
    echo "Repository updated in $folder_name"
fi
