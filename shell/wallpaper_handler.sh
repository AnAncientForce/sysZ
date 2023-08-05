#!/bin/bash

# Check if xdotool is installed
if ! command -v xdotool &>/dev/null; then
    echo "Error: xdotool is not installed. Please install it using your package manager."
    exit 1
fi

# Define the Alacritty window class name (it may vary depending on your setup)
ALACRITTY_WINDOW_CLASS="Alacritty"

# Check if Alacritty window is in focus
if xdotool getwindowfocus getwindowname | grep -q "$ALACRITTY_WINDOW_CLASS"; then
    echo "Alacritty is in focus."
else
    echo "Alacritty is not in focus."
fi
