#!/bin/bash



cu(){
    echo "Copying new files..."
    cp "conf/i3" "/home/$(whoami)/.config/i3/config"
    cp "conf/kitty.conf" "/home/$(whoami)/.config/kitty/"
    cp "conf/alacritty.yml" "/home/$(whoami)/.config/"
}
themes_setup(){
    echo "Installing themes"
    cd
    git clone --depth=1 https://github.com/adi1090x/rofi.git
    cd rofi
    chmod +x setup.sh
    ./setup.sh
}
repo_pull(){
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

# Run specific function is specified
if [ "$1" == "--function" ]; then
    shift  # Shift the arguments to skip the "--function" flag
    function_name="$1"
    shift  # Shift again to skip the function name

    # Call the specified function
    "$function_name"
fi

# Store the current directory
current_dir=$(pwd)

# Change directory to sysZ root
cd "$(dirname "$0")"

repo_pull

echo "Updating configuration files"
cu

echo "Scanning for changes in default applications"

read -p "
(i) Install recommended applications (if not already installed)
(c) Check for system update
(b) Both
(s) Skip
(i/c/s): " choice

if [ "$choice" = "b" ] || [ "$choice" = "u" ] || [ "$choice" = "n" ]; then
    if [ "$choice" = "i" ]; then
        sh shell/basepkg.sh
    elif [ "$choice" = "u" ]; then
        sudo pacman -Syu
        elif [ "$choice" = "b" ]; then
        sudo pacman -Syu
        sh shell/basepkg.sh
    elif [ "$choice" = "s" ]; then
        echo "Skipping..."
    fi
else
    echo "Skipping..."
fi
echo "Rendering lockscreen"
betterlockscreen ~/sysZ/bg.png

read -p "
[CAUTION]: rofi will not function correctly without this due to how the current configuration is setup
Check if themes are installed? (if not, install them)
(y/n): " choice
if [ "$choice" = "y" ]; then
    themes_setup
else
    echo "CAUTION: super + d may not work/function correctly"
fi





#echo "Checking python setup..."
#python3 -m venv .venv
#source .venv/bin/activate
#python3 -m pip install -r requirements.txt

echo "Restarting shell"
i3-msg 'exec python ~/sysZ/splash.py load;'
# sh shell/setup.sh
echo "===> All done! :)"

# Return to the original directory
cd "$current_dir"