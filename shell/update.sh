#!/bin/bash

usb_path="/run/media/$USER/PROJECT"  # Replace with the actual mount path of the USB drive
folder="sysZ"

# Check if the USB drive is mounted
if [ ! -d "$usb_path" ]; then
    echo "USB drive is not mounted. Please insert the USB drive and try again."
    exit 1
fi

# Check if the folder to copy exists in the USB drive
if [ ! -d "$usb_path/$folder" ]; then
    echo "Folder '$folder' not found in the USB drive."
    exit 1
fi

# Get the user's home directory
home_dir=$(eval echo "~$USER")

# Copy the folder to the home directory and replace existing files
cp -rf "$usb_path/$folder" "$home_dir"

echo "Folder '$folder' copied to the home directory successfully."
