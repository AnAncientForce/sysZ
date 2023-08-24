#!/bin/bash
# Github > @AnAncientForce > sysZ

# installable packages
pacman_packages=(
    "adobe-source-han-sans-jp-fonts"
    "adobe-source-han-sans-otc-fonts"
    "adobe-source-han-serif-otc-fonts"
    "alacritty"
    "ark"
    "brightnessctl"
    "calcurse"
    "feh"
    "filelight"
    "git"
    "gvfs"
    "kitty"
    "kvantum"
    "mpv-mpris"
    "neofetch"
    "pavucontrol"
    "polybar"
    "rofi"
    "sox"
    "thunar"
    "tldr"
    "wget"
    "zip"
    "python-pip"
    "tk"
    "lxappearance"
    "qt5ct"
    "jq"
    "python-pillow"
    "breeze"
    "base-devel"
    "git"
    "xfce4-screenshooter"
    "copyq"
    "plasma-systemmonitor"
    "ntfs-3g"
    "fuse"
    "thunar-volman"
    "curl"
    "cmatrix"
    "socat"
    "xdotool"
    "playerctl"
    "bluez"
    "bluez-utils"
    "conky"
    "noto-fonts"
    "font-manager"
    "timeshift"
    "tumbler"
    "ffmpegthumbnailer"
    "npm"
    "xorg-xinit"
)
# Disable "FreeMono"
yay_packages=(
    "vimix-gtk-themes"
    "vimix-cursors"
    "vimix-icon-theme"
    "cava-git"
    "librewolf-bin"
    "picom-simpleanims-git"
    "autotiling"
    "ttf-font-awesome-4"
    "tty-clock"
    "pipes.sh"
)
wallpapers=(
    "https://images6.alphacoders.com/131/1317292.jpeg"
    "https://images2.alphacoders.com/131/1317287.png"
    "https://images6.alphacoders.com/131/1317293.png"
    "https://images2.alphacoders.com/131/1317263.png"
    "https://images8.alphacoders.com/131/1317230.jpeg"
    "https://images2.alphacoders.com/131/1317346.png"
    "https://images4.alphacoders.com/131/1317261.jpeg"
    "https://images.alphacoders.com/131/1317297.png"
    "https://images8.alphacoders.com/131/1317219.jpeg"
    "https://images6.alphacoders.com/131/1317345.png"
    "https://images.alphacoders.com/131/1317226.jpeg"
    "https://images7.alphacoders.com/131/1317264.png"
    "https://images3.alphacoders.com/131/1317229.jpeg"
    "https://images8.alphacoders.com/131/1317224.jpeg"
    "https://images3.alphacoders.com/131/1317257.png"
)

Color_Off='\033[0m'
BBlack='\033[1;30m' BRed='\033[1;31m' BGreen='\033[1;32m' BYellow='\033[1;33m'
BBlue='\033[1;34m' BPurple='\033[1;35m' BCyan='\033[1;36m' BWhite='\033[1;37m'

# flag bools
valid_flag=false
automatic=false
run_as_root=false
update_check=false
install_pacman=false
install_yay=false
wm_setup=false
update_sysZ=false
first_setup=false
change_wallpaper=false
view_docs=false
update_confirm=false
dev_mode=true
change_live_wallpaper=false
auto_relaunch=false
routine=false
user_home=""
json_file=""
sysZ=""
temp_dir=""
node_path=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    json_file="/home/$SUDO_USER/.config/sysZ/config.json"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    json_file="/home/$(whoami)/.config/sysZ/config.json"
    user_home="/home/$(whoami)"
fi
temp_dir="$user_home/tmp"
node_path="$sysZ/node"

saveJson() {
    local key="$1"
    local value="$2"

    # Check if the value is either "true" or "false"
    if [ "$value" = "true" ] || [ "$value" = "false" ]; then
        # Use the already declared $json_file variable to read the JSON content and update the value of the provided key
        jq ".$key = $value" "$json_file" >"$json_file.tmp" && mv "$json_file.tmp" "$json_file"
        echo "JSON value for key '$key' has been set to $value."
    else
        echo "Invalid value provided. Only 'true' or 'false' allowed."
        return 1 # Invalid value
    fi
}

checkJson() {
    # Check if the file exists
    if [ -f "$json_file" ]; then
        # Use jq to read the JSON content and extract the value of the provided key
        value=$(jq -r ".$1" "$json_file")

        # Check if the value is true or false and return accordingly
        if [ "$value" = "true" ]; then
            return 0 # true
        else
            return 1 # false
        fi
    else
        echo "JSON file not found: $json_file"
        return 2 # File not found
    fi
}

function is_package_installed() {
    local package_name="$1"
    yay -Qs "$package_name" &>/dev/null
}

store_pid() {
    local custom_file="$1"
    local pid=$!
    mkdir -p "$(dirname "$custom_file")"
    echo "$pid" >"$custom_file"
}

kill_pid() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if [ -n "$pid" ]; then
            kill -9 "$pid"
            echo "Process with PID $pid has been terminated."
        else
            echo "PID not found in the file $pid_file."
        fi
        # Clean up the PID file
        rm "$pid_file"
    else
        echo "PID file $pid_file not found."
    fi
}
# ================================================================================ WALLPAPER

download_wallpapers_func() {
    echo -e "${BYellow}[*] Downloading wallpapers. This may take a while.\n${Color_Off}"
    mkdir -p "$sysZ/wallpapers"
    for url in "${wallpapers[@]}"; do
        filename=$(basename "$url")
        if [ -f "$sysZ/wallpapers/$filename" ]; then
            echo "Skipped $filename"
        else
            wget -q -nc "$url" -P "$sysZ/wallpapers"
            echo "Downloaded $filename"
        fi
    done
    echo -e "${BGreen}[*] Download successful\n${Color_Off}"
}

set_live_wallpaper() {
    kill_wallpaper_handler
    killall -9 feh xwinwrap mpv wallpaper_handler.sh
    sleep 0.1
    xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv --input-ipc-server=/tmp/mpvsocket -wid WID --loop --no-audio $sysZ/vid.mp4
    # --input-ipc-server=/tmp/mpvsocket
    # Save process id to kill later
    # sh $sysZ/shell/wallpaper_handler.sh &
    sh $sysZ/shell/wallpaper_handler.sh >/dev/null 2>&1 &
    store_pid "$temp_dir/wallpaper_handler_pid.txt"
}

kill_wallpaper_handler() {
    kill_pid "$temp_dir/wallpaper_handler_pid.txt"
}

change_wallpaper_func() {
    killall -9 xwinwrap
    local x='.*'
    local FILES=$sysZ/wallpapers/*
    local index=0
    local max=0
    while true; do
        let "max=0"
        let "index=0"
        for f in $FILES; do
            let "max=max+1"
        done
        # --------------------------

        for f in $FILES; do
            echo $f
            let "index=index+1"
            feh --bg-fill $f
            read -p "($index/$max) Set this wallpaper? : " yn
            case $yn in
            [Yy]*)
                echo "The wallpaper $name has been set"
                cp -v $f $sysZ/bg
                saveJson "live_wallpaper" "false"
                exit 2
                # v logging
                # f Do not prompt for confirmation before overwriting existing files
                break
                ;;
            [Bb]*)
                echo "nevermind Reversed Index"
                ;;
            [Nn]*) ;;
            *) ;; # echo "Please answer y or n";;
            esac
        done

        while true; do
            read -p "Loop through the wallpapers again? : " yn
            case $yn in
            [Yy]*) break ;;
            [Nn]*) exit ;;
            *) echo "Please answer y or n" ;;
            esac # 'esac' end case statement
        done
    done
    exit 0
}

change_live_wallpaper_func() {
    local x='.*'
    local FILES=$sysZ/videos/*
    local index=0
    local max=0
    killall -9 feh xwinwrap
    sleep 0.1
    while true; do
        let "max=0"
        let "index=0"
        for f in $FILES; do
            let "max=max+1"
        done
        # --------------------------

        for f in $FILES; do
            echo $f
            let "index=index+1"
            # feh --bg-fill $f
            killall -9 xwinwrap
            xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv -wid WID --loop --no-audio $f
            read -p "($index/$max) Set this live wallpaper? : " yn
            case $yn in
            [Yy]*)
                echo "The wallpaper $name has been set"
                cp -v $f $sysZ/vid.mp4
                saveJson "live_wallpaper" "true"
                set_live_wallpaper
                # cp -v $f $sysZ/bg
                exit 2
                break
                ;;
            [Bb]*)
                echo "nevermind Reversed Index"
                ;;
            [Nn]*) ;;
            *) ;;
            esac
        done
        while true; do
            read -p "Loop through the wallpapers again? : " yn
            case $yn in
            [Yy]*) break ;;
            [Nn]*) exit ;;
            *) echo "Please answer y or n" ;;
            esac
        done
    done
    exit 0
}
# ================================================================================ GENERAL
root_cmd() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${BRed}[!] Must be running as sudo or root${Color_Off}"
        exit 1
    fi
    read -p "Setup QT_QPA_PLATFORMTHEME?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        echo -e "${BRed}[*] Setting up QT_QPA_PLATFORMTHEME in /etc/environment...${Color_Off}"
        echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
    fi
}

repo_pull() {
    echo -e ${BPurple}"[*] Checking for repository changes\n" ${Color_Off}
    # Store the current directory
    current_dir=$(pwd)

    # Change directory to sysZ root
    cd "$(dirname "$0")"

    # Check if it's a git repository before performing git pull
    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Reset to the remote branch forcefully
        git fetch origin main
        git reset --hard origin/main
        echo "Repository updated."
    else
        echo "Initializing a new git repository..."
        git init
        git remote add origin https://github.com/AnAncientForce/sysZ.git
        git fetch origin main
        git checkout -b main --track origin/main
        echo "Git repository set up. Repository is ready."
    fi
    chmod +x $sysZ/shell/pull.sh
    echo -e ${BBlue}"[?] You can CTRL+C & relaunch to quickly apply script updates\n" ${Color_Off}
    #if [ "$auto_relaunch" = true ] && [ -f "$sysZ/shell/pull.sh" ]; then
    #    echo -e ${BBlue}"[*] Relaunching sysZ\n" ${Color_Off}
    #    exec ./$sysZ/shell/pull.sh
    #    echo -e ${BRed}"[!] Terminating current process\n" ${Color_Off}
    #    exit 0
    #fi
}

cu() {
    echo -e "${BPurple}[*] Updating configuration files${Color_Off}"
    mkdir -p "$user_home/.config/sysZ"
    mkdir -p "$user_home/.config/kitty"
    mkdir -p "$user_home/.config/conky"
    cp "$sysZ/conf/i3" "$user_home/.config/i3/config"
    cp "$sysZ/conf/kitty.conf" "$user_home/.config/kitty"
    cp "$sysZ/conf/conky.conf" "$user_home/.config/conky"
    cp "$sysZ/conf/alacritty.yml" "$user_home/.config"
    cp "$sysZ/conf/.bashrc" "$user_home"
    # cp "$sysZ/conf/.Xresources" "$user_home"
}

ex() {
    echo -e ${BPurple}"[*] Making shell scripts executable\n" ${Color_Off}
    for file in "$sysZ/shell"/*.sh; do
        if [ -f "$file" ] && [ ! -x "$file" ]; then
            chmod +x "$file"
        fi
    done
}
# ================================================================================ INSTALLS
npm_setup() {
    cd ~
    cd "$sysZ/node"
    npm install
}
git_install_rofi() {
    cd ~
    git clone --depth=1 https://github.com/adi1090x/rofi.git
    cd rofi
    chmod +x setup.sh
    ./setup.sh
}
git_install_yay() {
    cd ~
    if [ -d "yay" ]; then
        rm -rf "yay"
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay --version
}
git_install_xwinwrap() {
    git clone https://github.com/ujjwal96/xwinwrap.git
    cd xwinwrap
    make
    sudo make install
    make clean
}
install_rec_pacman() {
    not_installed=0
    key="Arch"
    echo "Checking $key"
    # Check before warning prompt
    for package in "${pacman_packages[@]}"; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            not_installed=1
            break # Break out of the loop as soon as we find a package that needs installation
        fi
    done
    if [ $not_installed -eq 1 ]; then
        # Now for the real install
        echo -e ${BRed}"[*] Attention Required\n" ${Color_Off}
        for package in "${pacman_packages[@]}"; do
            if ! pacman -Qi "$package" >/dev/null 2>&1; then
                sudo pacman -S --noconfirm "$package"
            fi
        done
    else
        echo -e "${BGreen}[*] $key packages are already installed\n${Color_Off}"
    fi
}

install_rec_yay() {
    not_installed=0
    key="AUR"
    echo "Checking $key"
    for package in "${yay_packages[@]}"; do
        if ! yay -Qs "$package" >/dev/null; then
            yay -S --noconfirm "$package"
            not_installed=1
        fi
    done
    if [ $not_installed -eq 1 ]; then
        echo "Some $key packages were installed."
    else
        echo -e "${BGreen}[*] $key packages are already installed\n${Color_Off}"
    fi

    if ! is_package_installed "betterlockscreen"; then
        echo -e "${BRed}[!] Attention Required${Color_Off}"
        yay -S betterlockscreen
    fi
}

manual() {
    echo -e ${BBlue}"\n[*] Manual update is starting..." ${Color_Off}
    repo_pull

    # configuration files
    cu

    # make files executable
    ex

    # install yay
    read -p "[Required] Install Yay?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_yay
    fi

    # packages & update
    echo -e "${BPurple}[*] System Upgrade${Color_Off}"
    read -p "
    (y) Install Yay packages
    (p) Install Pacman packages
    (b) Install Both packages (yay & pacman)
    (u) System Update
    (a) All
    (s) Skip
    " choice

    if [ "$choice" = "y" ]; then
        install_rec_yay

    elif [ "$choice" = "p" ]; then
        install_rec_pacman

    elif [ "$choice" = "b" ]; then
        install_rec_yay
        install_rec_pacman

    elif [ "$choice" = "u" ]; then
        echo -e "${BRed}[*] Attention Required\nAbout to perform a system update...${Color_Off}"
        sudo pacman -Syu

    elif [ "$choice" = "a" ]; then
        install_rec_yay
        echo -e "${BRed}[*] Attention Required${Color_Off}"
        install_rec_pacman
        sudo pacman -Syu

    elif [ "$choice" = "s" ]; then
        echo -e "${BPurple}[*] Skipping...${Color_Off}"

    else
        echo "Skipping..."
    fi

    # sysZ / config.json
    read -p "
    [Required if setting up for the very first time] Copy default sysZ config file?
    " choice
    if [ "$choice" = "y" ]; then
        cp "$user_home/sysZ/conf/config.json" "$user_home/.config/sysZ"
        if [ -f "$user_home/.config/sysZ/config.json" ]; then
            echo "sysZ config copied successfully"
        else
            echo "sysZ config did not copy successfully"
        fi
    else
        echo "config.json was not replaced"
    fi

    echo "Scanning for changes in default applications"

    # setup npm
    read -p "[Required] Setup sysZ settings gui?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        npm_setup
    fi

    # install xwinwrap
    read -p "[Required] Install xwinwrap?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_xwinwrap
    fi

    # install starship
    read -p "[Required] Install starship?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        cd ~
        curl -sS https://starship.rs/install.sh | sh
    fi

    # rofi
    read -p "[Required]: Install rofi themes?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_rofi
    fi

    # wallpapers
    read -p "Download wallpapers?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        download_wallpapers_func
    fi

    # root
    read -p "Setup QT_QPA_PLATFORMTHEME?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        sudo sh $sysZ/shell/root.sh
    fi

    # render lockscreen
    continue_setup_func

    # end
    # echo "===> All done! :)"
    # echo -e ${BGreen}"[*] Setup has finished\n" ${Color_Off}
    cd "$current_dir"
}

check_updates() {
    if ! checkJson "ignore_updates"; then
        current_dir=$(pwd)
        cd $sysZ

        if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git remote update >/dev/null 2>&1
            if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
                #.........
                # python /home/$(whoami)/sysZ/main.py update_confirmation
                # alacritty -e sh -c "cd $sysZ/shell; pull.sh --update-confirm; $SHELL"
                alacritty -e bash -c "cd $sysZ/shell && ./pull.sh --update-confirm; $SHELL"
                exit 0
            else
                echo "No updates available."
            fi
        fi
    fi
}

automatic_setup_func() {
    echo -e ${BGreen}"[*] Automatic Setup is starting...\n" ${Color_Off}
    repo_pull
    cu
    ex
    install_rec_yay
    install_rec_pacman
    continue_setup_func
    cd "$current_dir"
}

continue_setup_func() {
    if checkJson "render_lockscreen"; then
        echo -e "${BPurple}[*] Rendering lockscreen...${Color_Off}"
        betterlockscreen -u $sysZ/bg
    fi
}

view_docs_func() {
    if [ -z "$2" ]; then
        echo -e "${BRed}\n[!] Please provide a valid [doc] name.\n${Color_Off}"
        exit 2
    fi
    doc_name="$2"
    docs_path="$sysZ/docs/$doc_name.txt"
    if [ -f "$docs_path" ]; then
        cat "$docs_path"
        exit 0
    else
        echo -e "${BRed}\n[!] Invalid document\n${Color_Off}"
        echo -e ${BGreen}"[*] --docs        : View docs: [bluetooth, i3, pkgs, print, tools]" ${Color_Off}
        exit 2
    fi
}

update_confirm_func() {
    echo -e ${BGreen}"\nA new update is now available!\n" ${Color_Off}
    read -p "Proceed & Update?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        update_sysZ_func
    else
        echo -e ${BRed}"\nUpdate did not proceed\n" ${Color_Off}
    fi
}

update_sysZ_func() {
    repo_pull
    cu
    ex
    install_rec_pacman
    install_rec_yay
    wm_setup_func
}

routine_func() {
    repo_pull
    cu
    ex
    install_rec_yay
    sudo pacman -Syu
    install_rec_pacman
    continue_setup_func
    wm_setup_func
}

wm_setup_func() {
    killall -9 polybar copyq feh xwinwrap picom conky
    sleep 0.1
    echo -e ${BBlue}"\n[*] wm-refresh" ${Color_Off}
    i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"
    i3-msg "exec copyq;"
    i3-msg "exec sox $sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
    if checkJson "show_resources_monitor"; then
        i3-msg "exec conky -d &;"
    fi
    if checkJson "use_background_blur"; then
        i3-msg 'exec picom -b --config ~/sysZ/conf/picom.conf --blur-background --backend glx;'
    else
        i3-msg 'exec picom -b --config ~/sysZ/conf/picom.conf;'
    fi
    if checkJson "live_wallpaper"; then
        set_live_wallpaper
        cpu_usage=$(top -b -n 1 | awk '/^%Cpu/{print $2}')
        if [ $(echo "$cpu_usage > 50" | bc -l) -eq 1 ]; then
            echo -e "\n[!] Caution: CPU usage may significantly increase while using Live Wallpaper\n"
        fi
    else
        i3-msg "exec feh --bg-fill $sysZ/bg;"
    fi
    i3-msg "reload"

    # i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    # i3-msg 'exec picom -b --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'
    # check_updates
    # echo -e "${BRed}[!] Please manually refresh (CTRL+SHIFT+R)\n${Color_Off}"
    # read -p "Press [Enter] to continue..."
}

function trap_ctrlc() {
    echo -e ${BRed}"\n[!] The current operation has been stopped.\n" ${Color_Off}
    exit 2
}
trap "trap_ctrlc" 2

# echo -e ${BBlue}"\n[*] A" ${Color_Off}
# echo -e ${BYellow}"[*] B\n" ${Color_Off}
# echo -e ${BPurple}"[*] C" ${Color_Off}
# echo -e ${BBlue}"[*] D" ${Color_Off}
# echo -e ${BGreen}"[*] E\n" ${Color_Off}
# echo -e ${BRed}"[!] F\n" ${Color_Off}

# first time setup, first time setup for sysZ (asks questions)
# regular setup, includes repo updates & system updates & new recommended package downloads
# sysZ-update, gets github updates

# echo "Available flags:"
# echo "--automatic    : Checks repository for updates & automatically installs them"
# echo "--root         : Manual setup with root privileges"
# echo "--pacman       : Installs recommended Arch Linux packages"
# echo "--yay          : Installs recommended Arch User Repository packages"
# echo "--setup        : Reloads sysZ's integration of the window manager"
# echo "--update-check : Checks for repository updates. Returns true or false (dose not update anything)"

# ----------------------------- Flag Logic

help() {
    echo -e ${BPurple}"Usage\n" ${Color_Off}
    # echo -e ${BBlue}"[*] chmod +x pull.sh" ${Color_Off}
    # echo -e ${BBlue}"[*] ./pull.sh -h" ${Color_Off}
    echo -e ${BBlue}"[>] sysz -h\n" ${Color_Off}
    echo -e ${BPurple}"Available flags\n" ${Color_Off}
    echo -e ${BGreen}"[*] -h            : Lists all available flags" ${Color_Off}
    echo -e ${BGreen}"[*] -u            : Updates sysZ (automatically installs dependencies)" ${Color_Off}
    echo -e ${BGreen}"[*] -l            : Lock Workstation" ${Color_Off}
    echo -e ${BGreen}"[*] -r            : Refreshes i3-wm" ${Color_Off}
    echo -e ${BGreen}"[*] --cw          : Change Wallpaper" ${Color_Off}
    echo -e ${BGreen}"[*] --lw          : Change Live Wallpaper" ${Color_Off}
    echo -e ${BGreen}"[*] --ca          : Change Appearance" ${Color_Off}
    echo -e ${BGreen}"[*] --docs        : View docs: [bluetooth, i3, pkgs, print, tools]" ${Color_Off}
    echo -e ${BGreen}"[*] --set         : sysZ settings | Usage: --set [w _KEY _BOOL, r]" ${Color_Off}
    echo -e ${BGreen}"[*] --routine     : Updates sysZ (automatically installs dependencies) & Arch Linux" ${Color_Off}
    echo -e ${BGreen}"[*] --first-setup : Runs the first time setup installer" ${Color_Off}
    echo -e ${BGreen}"[*] --root        : Runs the first time [root] setup installer" ${Color_Off}
    # echo -e ${BGreen}"[*] --automatic   : Updates sysZ & Updates Arch Linux & Installs any new recommended packages" ${Color_Off}
    exit 0
}

echo -e ${BPurple}"[*] sysZ\n" ${Color_Off}
if [ "$1" = "-h" ]; then
    help
fi

for arg in "$@"; do
    case "$arg" in
    --root)
        run_as_root=true
        valid_flag=true
        ;;
    --update-check)
        update_check=true
        valid_flag=true
        ;;
    --first-setup)
        first_setup=true
        valid_flag=true
        ;;
    --update-confirm)
        update_confirm=true
        valid_flag=true
        ;;
    -u)
        update_sysZ=true
        valid_flag=true
        ;;
    --cw)
        # change_wallpaper=true
        # valid_flag=true
        change_wallpaper_func
        exit 0
        ;;
    --ca)
        i3-msg 'exec qt5ct; exec lxappearance; exec font-manager;'
        exit 0
        ;;
    -l)
        i3-msg 'exec betterlockscreen -l dimblur;'
        exit 0
        ;;
    -r)
        wm_setup_func
        exit 0
        ;;
    --lw)
        echo -e ${BPurple}"Change Live Wallpaper\n" ${Color_Off}
        change_live_wallpaper_func
        exit 0
        ;;
    --docs)
        view_docs=true
        valid_flag=true
        ;;
    --routine)
        routine=true
        valid_flag=true
        ;;
    --set)
        # $2 == operation (w, r)
        # $3 == value to write
        # $4 == value
        if [ -z "$2" ]; then
            echo -e "${BRed}\n[!] Invalid operation (r, w)\n${Color_Off}"
            exit 2
        fi
        if [ "$2" = "r" ]; then
            cat "$json_file"
        fi
        if [ "$2" = "w" ]; then
            if [ -z "$3" ]; then
                echo -e "${BRed}\n[!] Cannot write empty key\n${Color_Off}"
                exit 2
            fi
            saveJson "$3" "$4"
            if [ $? -eq 0 ]; then
                echo -e "${BBlue}\nSaved : $3 : $4\n${Color_Off}"
            else
                echo -e "${BRed}\n[!] Expected _BOOLEAN\n${Color_Off}"
            fi
        fi
        exit 0
        # ================================================================================ ^
        ;;
    --dev)
        dev_mode=true
        valid_flag=true
        ;;
    --setup)
        wm_setup=true
        valid_flag=true
        ;;
    --automatic)
        automatic=true
        valid_flag=true
        ;;
    --cd)
        cd "$sysZ/shell"
        echo -e ${BGreen}"\nDirectory Changed\n" ${Color_Off}
        exit 0
        ;;
    --pacman)
        install_pacman=true
        valid_flag=true
        ;;
    --yay)
        install_yay=true
        valid_flag=true
        ;;
    -k)
        echo -e ${BRed}"kill_wallpaper_handler\n" ${Color_Off}
        kill_wallpaper_handler
        exit 0
        ;;
    -a)
        auto_relaunch=true
        ;;
    *) ;;
    esac
done
if ! $valid_flag; then
    # echo -e ${BRed}"\n[!] Incorrect or misspelled flag.\n\nProceeding with default...\n" ${Color_Off}
    if [ $# -eq 0 ]; then
        echo -e "${BRed}[!] No flags were supplied.\n${Color_Off}"
    else
        echo -e ${BRed}"[!] Incorrect or misspelled flag.\n" ${Color_Off}
    fi
    echo -e ${BBlue}"[?] Usage: sysz -h" ${Color_Off}
    exit 2
fi

if [ "$automatic" = true ]; then
    automatic_setup_func

elif [ "$run_as_root" = true ]; then
    root_cmd

elif [ "$update_check" = true ]; then
    check_updates

elif [ "$install_pacman" = true ]; then
    install_rec_pacman

elif [ "$install_yay" = true ]; then
    install_rec_yay

elif [ "$wm_setup" = true ]; then
    wm_setup_func

elif [ "$first_setup" = true ]; then
    manual

elif [ "$update_sysZ" = true ]; then
    update_sysZ_func

elif [ "$change_wallpaper" = true ]; then
    change_wallpaper_func

elif [ "$update_confirm" = true ]; then
    update_confirm_func

elif [ "$view_docs" = true ]; then
    view_docs_func "$@"

elif [ "$routine" = true ]; then
    routine_func

elif [ "$dev_mode" = true ]; then
    read -p "Install ujjwal96/xwinwrap?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_xwinwrap
    else
        echo -e ${BRed}"\nStop\n" ${Color_Off}
    fi

    read -p "Run live wallpaper?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        set_live_wallpaper
    else
        echo -e ${BRed}"\nStop\n" ${Color_Off}
    fi
    exit 0
fi
echo -e ${BGreen}"[*] Setup has finished\n" ${Color_Off}
#....
