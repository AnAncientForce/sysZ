#!/bin/bash
# Github > @AnAncientForce > sysZ
# installable packages
pacman_packages=(
    "adobe-source-han-sans-jp-fonts"
    "adobe-source-han-sans-otc-fonts"
    "adobe-source-han-serif-otc-fonts"
    "noto-fonts-emoji"
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
    "blueman"
    "conky"
    "noto-fonts"
    "font-manager"
    "timeshift"
    "tumbler"
    "ffmpegthumbnailer"
    "npm"
    "xorg-xinit"
    "xfce4-settings"
    "gedit"
    "dunst"
    "arandr"
    "python-pipx"
    "htop"
    "linux-headers"
    "xf86-input-synaptics"
)
# Disable "FreeMono"
yay_packages=(
    "xidlehook"
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
    "ungoogled-chromium-bin"
    "droidcam"
)
removed_packages=(
    "xidlehook"
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
    "ungoogled-chromium-bin"
    "droidcam"
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
dev_mode=false
change_live_wallpaper=false
auto_relaunch=false
routine=false
quick_refresh=false
auto_sysZ_install=false
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
source "$sysZ/shell/common.sh"

validate_keys() {
    echo -e ${BPurple}"[*] Please open the main interface to automatically validate json keys\n" ${Color_Off}
}

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
    if [ -f "$user_home/.config/rofi/launchers/type-1/launcher.sh" ]; then
        cp "$sysZ/conf/rofi/config.rasi" "$user_home/.config/rofi"
        cp "$sysZ/conf/rofi/fonts.rasi" "$user_home/.config/rofi/launchers/type-5/shared"
        cp "$sysZ/conf/rofi/launcher.sh" "$user_home/.config/rofi/launchers/type-1"
    fi
    if [ ! -f "$user_home/.config/sysZ/autostart.sh" ]; then
        mkdir -p "$user_home/.config/sysZ"
        cp "$sysZ/conf/autostart.sh" "$user_home/.config/sysZ"
    fi
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
    # makepkg -si
    yes | makepkg -si
    yay --version
}
git_install_xwinwrap() {
    git clone https://github.com/ujjwal96/xwinwrap.git
    cd xwinwrap
    make
    # sudo make install
    sudo make DESTDIR=/usr/local install
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

# ==================
empty_folder() {
    local folder_path="$1"
    if [ -d "$folder_path" ]; then
        cd "$folder_path"
        for file in *; do
            if [ -f "$file" ]; then
                rm "$file"
            fi
        done
    else
        echo "Folder does not exist $folder_path"
    fi
}

auto_sysZ_install_func() {

    # privileges check
    if ! groups | grep -q '\<wheel\>'; then
        echo -e "${BRed}\n[!] The current user must be in the sudoers wheel group." "${Color_Off}"
        return 1
    fi
    echo -e "${BRed}\n[*] Please note that:" "${Color_Off}"
    echo -e "${BPurple}\n[*] Throughout the installation you will be asked to enter your sudo password multiple time(s)." "${Color_Off}"
    echo -e "${BPurple}\n[*] When the installation completes you wil automatically be logged out." "${Color_Off}"
    read -p "Start the automatic installer?
    (y/n): " choice
    if [ "$choice" != "y" ]; then
        echo -e "${BRed}\n[!] Installer has stopped" "${Color_Off}"
        return 1
    fi

    echo -e ${BBlue}"\n[*] Automatic install is starting; information will be logged at all times." ${Color_Off}

    if [ -f "$user_home/.config/sysZ" ]; then
        echo "Deleting sysZ configurations..."
        rm -r "$user_home/.config/sysZ"
    fi
    if [ -d "$sysZ" ]; then
        empty_folder "$sysZ/node/node_modules"
    fi

    repo_pull

    # configuration files
    cu

    # make files executable
    ex

    # validate json keys
    validate_keys

    # install yay
    git_install_yay

    # packages & update
    install_rec_yay
    echo -e "${BRed}[*] Attention Required${Color_Off}"
    install_rec_pacman
    sudo pacman -Syu

    # sysZ / config.json
    cp "$user_home/sysZ/conf/config.json" "$user_home/.config/sysZ"
    cp "$user_home/sysZ/conf/autostart.sh" "$user_home/.config/sysZ"
    if [ -f "$user_home/.config/sysZ/config.json" ]; then
        echo "sysZ config copied successfully"
    else
        echo "sysZ config did not copy successfully"
    fi

    echo "Scanning for changes in default applications"

    # setup npm
    npm_setup

    # install xwinwrap
    git_install_xwinwrap

    # install starship
    cd ~
    export STARSHIP_INIT=1
    curl -sS https://starship.rs/install.sh | sh

    # rofi
    git_install_rofi

    # wallpapers
    download_wallpapers_func

    # root (QT_QPA_PLATFORMTHEME?)
    sudo sh $sysZ/shell/root.sh

    # set default wallpaper
    # cp -v $sysZ/wallpapers/sysz-default-bg.png $sysZ/saved/bg
    saveJson "live_wallpaper" "false"

    # render lockscreen
    continue_setup_func

    cd "$current_dir"

    i3-msg exit
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

continue_setup_func() {
    if checkJson "render_lockscreen"; then
        echo -e "${BPurple}[*] Rendering lockscreen...${Color_Off}"
        wallpaper_path=$(checkJsonString "wallpaper_path")
        if [ $? -eq 0 ] && [ -n "$wallpaper_path" ]; then
            betterlockscreen -u $wallpaper_path
        fi
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
    validate_keys
    install_rec_yay
    install_rec_pacman
    wm_setup_func
}

wallpaper_management_func() {
    if checkJson "live_wallpaper"; then
        live_wallpaper_path=$(checkJsonString "live_wallpaper_path")
        if [ $? -eq 0 ] && [ -n "$live_wallpaper_path" ]; then
            kill_pid "$temp_dir/wallpaper_handler_pid.txt"
            killall feh xwinwrap mpv wallpaper_handler.sh
            sleep 0.1
            # xwinwrap -fs -ov -ni -nf -un -s -d -o 1.0 -debug -- mpv --input-ipc-server=/tmp/mpvsocket -wid WID --loop --no-audio "$live_wallpaper_path"
            sh $sysZ/shell/wallpaper_handler.sh >/dev/null 2>&1 &
            store_pid "$temp_dir/wallpaper_handler_pid.txt"

            cpu_usage=$(top -b -n 1 | awk '/^%Cpu/{print $2}')
            if [ $(echo "$cpu_usage > 50" | bc -l) -eq 1 ]; then
                echo -e "\n[!] Caution: CPU usage may significantly increase while using Live Wallpaper\n"
            fi
        fi
    else
        wallpaper_path=$(checkJsonString "wallpaper_path")
        if [ $? -eq 0 ] && [ -n "$wallpaper_path" ]; then
            killall feh
            i3-msg "exec feh --bg-fill $wallpaper_path"
        fi
    fi
}

screensaver_func() {
    screensaver_timeout=$(checkJsonString "screensaver_timeout")
    if [[ $screensaver_timeout =~ ^[0-9]+$ ]]; then
        screensaver_timeout=$((screensaver_timeout * 60))
        # echo "Screensaver timeout in seconds: $screensaver_timeout"
    else
        echo "Invalid or non-numeric value for screensaver_timeout"
    fi
    # echo "screensaver_timeout: $screensaver_timeout"
    if [ "$screensaver_timeout" -gt 0 ]; then
        # echo "Screensaver: Enabled"
        kill_pid "$temp_dir/screensaver_launcher_pid.txt"
        killall xidlehook screensaver_launcher.sh
        sh $sysZ/shell/screensaver_launcher.sh $screensaver_timeout >/dev/null 2>&1 &
        store_pid "$temp_dir/screensaver_launcher_pid.txt"
    fi
}

wm_setup_func() {
    echo "wm-refresh" >>"${sysZ}/log.txt"
    echo -e ${BBlue}"\n[*] wm-refresh" ${Color_Off}
    killall polybar picom
    echo -e ${BBlue}"\n[*] Starting polybar" ${Color_Off}
    i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"

    if pgrep -x "copyq" >/dev/null; then
        echo -e ${BBlue}"\n[*] Enabling clipboard" ${Color_Off}
        i3-msg "exec copyq;"
    fi

    if ! checkJson "disable_sfx"; then
        i3-msg "exec sox $sysZ/sfx/M_UI_00000040.flac -d;"
    fi

    if checkJson "use_background_blur"; then
        i3-msg 'exec picom -b --config ~/sysZ/conf/picom.conf --blur-background --backend glx;'
    else
        i3-msg 'exec picom -b --config ~/sysZ/conf/picom.conf;'
    fi

    if checkJson "prevent_sleeping"; then
        echo -e ${BBlue}"\n[*] Preventing sleep" ${Color_Off}
        xset s off
        xset -dpms
    fi

    screensaver_func

    if checkJson "use_autotiling"; then
        echo -e ${BBlue}"\n[*] Enabling autotiling" ${Color_Off}
        i3-msg "exec autotiling;"
    fi

    if checkJson "enable_bluetooth"; then
        if [ "$(systemctl is-enabled bluetooth.service)" = "disabled" ]; then
            echo -e ${BRed}"\n[!] Requesting authentication to change bluetooth state > enabled" ${Color_Off}
            sudo systemctl enable bluetooth.service
            sudo systemctl start bluetooth.service
        fi
    else
        if [ "$(systemctl is-enabled bluetooth.service)" = "enabled" ]; then
            echo -e ${BRed}"\n[!] Requesting authentication to change bluetooth state > disabled" ${Color_Off}
            sudo systemctl disable bluetooth.service
            sudo systemctl stop bluetooth.service
        fi
    fi
    if [ -f "$user_home/.config/sysZ/autostart.sh" ]; then
        if ! checkJson "disable_autostart_file"; then
            i3-msg "exec sh $user_home/.config/sysZ/autostart.sh;"
        fi
    else
        echo -e ${BBlue}"\n[!] Autostart file not found" ${Color_Off}
    fi

    i3-msg "reload"
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

# ----------------------------- Flag Logic
gap="   "
help() {
    # echo -e ${BPurple}"Usage\n" ${Color_Off}
    # echo -e ${BBlue}"[>] sysz -h\n" ${Color_Off}
    # echo -e ${BGreen}"[*] --set         : sysZ settings | Usage: --set [w _KEY _BOOL, r]" ${Color_Off}
    # echo -e ${BGreen}"[*] -l            : Lock Workstation" ${Color_Off}
    echo -e ${BPurple}"Available flags (Example Usage: sysz -u)\n" ${Color_Off}
    echo -e ${BGreen}"[*] -h            : Lists all available flags" ${Color_Off}
    echo -e ${BGreen}"[*] -u            : Updates sysZ (automatically installs required dependencies)" ${Color_Off}
    echo -e ${BGreen}"[*] -r            : Refreshes sysZ" ${Color_Off}
    echo -e ${BGreen}"[*] -l            : Lock Workstation" ${Color_Off}
    echo -e ${BYellow}"[*] --auto        : Automatically installs sysZ" ${Color_Off}
    echo -e ${BRed}"[*] --set         : Manually edit settings | Usage: --set [w _KEY _BOOL, r]" ${Color_Off}
    echo -e ${BRed}"[*] --mod         : Additional configuration settings that aren't shown in the main interface." ${Color_Off}
    echo -e ${BBlue}"\n[?] For a general overview of how to navigate the system, press [SUPER + i] to open the main interface.\n$gap Once opened, click [Guides], then click [Global Shortcuts]" ${Color_Off}
    exit 0
}

echo -e ${BBlue}"sysZ\n" ${Color_Off}
if [ "$1" = "-h" ]; then
    help
fi

for arg in "$@"; do
    case "$arg" in
    --ss)
        screensaver_func
        exit 0
        ;;
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
    -ri3)
        cp "$sysZ/conf/i3" "$user_home/.config/i3/config"
        echo -e ${BGreen}"\nReset i3 config with default\n" ${Color_Off}
        exit 0
        ;;
    -k)
        echo -e ${BRed}"kill_wallpaper_handler\n" ${Color_Off}
        kill_pid "$temp_dir/wallpaper_handler_pid.txt"
        exit 0
        ;;
    -a)
        auto_relaunch=true
        ;;
    --apply-live)
        wallpaper_management_func
        valid_flag=true
        ;;
    --qr)
        repo_pull
        cu
        ex
        validate_keys
        wm_setup_func
        exit 0
        quick_refresh=true
        valid_flag=true
        ;;
    --auto)
        auto_sysZ_install=true
        valid_flag=true
        ;;
    --store-pid)
        if [ -z "$2" ]; then
            echo -e "${BRed}\n[!] Invalid operation (no option specified)\n${Color_Off}"
            exit 2
        fi
        store_pid $temp_dir/$2
        exit 0
        ;;
    --kill-pid)
        if [ -z "$2" ]; then
            echo -e "${BRed}\n[!] Invalid operation (no option specified)\n${Color_Off}"
            exit 2
        fi
        kill_pid $temp_dir/$2
        exit 0
        ;;
    --mod)
        # https://wiki.archlinux.org/title/Touchpad_Synaptics
        # https://archlinux.org/pacman/pacman.conf.5.html

        echo -e "${BPurple}[*] Checking backup directory has been created\n${Color_Off}"
        mkdir -p "$user_home/.config/emergency-restore"
        echo -e "${BBlue}[*] What would you like to do? Please choose an option.\n${Color_Off}"
        read -p "t = touchpad, p = pacman (t/p): " choice

        if [ "$choice" = "t" ]; then
            read -p "y = install, n = uninstall (y/n): " choice
            sudo cp "/etc/X11/xorg.conf.d/30-synaptics.conf" "$user_home/.config/emergency-restore/30-synaptics.conf"
            sudo cp "/etc/X11/xorg.conf.d/70-synaptics.conf" "$user_home/.config/emergency-restore/70-synaptics.conf"

            if [ "$choice" = "y" ]; then
                read -p "30-touchpad or 70-synaptics (30/70): " choice
                if [ "$choice" = "30" ]; then
                    sudo rm "/etc/X11/xorg.conf.d/70-synaptics.conf"
                    sudo cp "$sysZ/conf/30-touchpad.conf" "/etc/X11/xorg.conf.d/30-touchpad.conf"
                elif [ "$choice" = "70" ]; then
                    sudo rm "/etc/X11/xorg.conf.d/30-synaptics.conf"
                    sudo cp "$sysZ/conf/70-synaptics.conf" "/etc/X11/xorg.conf.d/70-synaptics.conf"
                fi
                echo -e "${BGreen}[*] Installed\n${Color_Off}"
            elif [ "$choice" = "n" ]; then
                sudo rm "/etc/X11/xorg.conf.d/30-touchpad.conf"
                sudo rm "/etc/X11/xorg.conf.d/70-synaptics.conf"
                echo -e "${BGreen}[*] Removed\n${Color_Off}"
            else
                echo -e "${BRed}[*] Invalid choice. Please enter 'y' to install or 'n' to uninstall.\n${Color_Off}"
                exit 0
            fi

        elif [ "$choice" = "p" ]; then
            sudo cp "/etc/pacman.conf" "$user_home/.config/emergency-restore/pacman.conf"
            sudo cp "$sysZ/conf/pacman.conf" "/etc/pacman.conf"
            echo -e "${BGreen}[*] Installed\n${Color_Off}"
        else
            echo -e "${BRed}[*] Invalid choice\n${Color_Off}"
            exit 0
        fi
        echo -e "${BGreen}[*] Success\n${Color_Off}"
        exit 0
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

elif [ "$quick_refresh" = true ]; then
    quick_refresh_func

elif [ "$auto_sysZ_install" = true ]; then
    auto_sysZ_install_func

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
