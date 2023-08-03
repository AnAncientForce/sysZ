#!/bin/bash
# Github > @AnAncientForce > sysZ
sysZ="/home/$(whoami)/sysZ"

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
)
yay_packages=(
    "vimix-gtk-themes"
    "vimix-cursors"
    "vimix-icon-theme"
    "cava-git"
    "librewolf-bin"
    "picom-simpleanims-git"
    "autotiling"
    "ttf-font-awesome-4"
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

checkJson() {
    json_file="/home/$(whoami)/.config/sysZ/config.json"

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

root_cmd() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "[!] - Run as sudo or as root"
        exit 1
    fi

    echo "Root setup has started"

    read -p "
    Install pacman packages & system update?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        sudo pacman -Syu
        sudo -u $SUDO_USER sh /home/$SUDO_USER/sysZ/shell/pacman.sh
    fi

    read -p "${BPurple}
    Setup QT_QPA_PLATFORMTHEME?
    (y/n): ${Color_Off}" choice

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

cu() {
    echo -e ${BPurple}"[*] Updating configuration files\n" ${Color_Off}
    mkdir -p "/home/$(whoami)/.config/kitty"
    cp "$sysZ/conf/i3" "/home/$(whoami)/.config/i3/config"
    cp "$sysZ/conf/kitty.conf" "/home/$(whoami)/.config/kitty"
    cp "$sysZ/conf/alacritty.yml" "/home/$(whoami)/.config"
}

ex() {
    echo -e ${BPurple}"[*] Making shell scripts executable\n" ${Color_Off}
    for file in "$sysZ/shell"/*.sh; do
        if [ -f "$file" ] && [ ! -x "$file" ]; then
            chmod +x "$file"
        fi
    done
}

git_install_rofi() {
    echo "Installing > https://github.com/adi1090x/rofi.git"
    cd ~
    git clone --depth=1 https://github.com/adi1090x/rofi.git
    cd rofi
    chmod +x setup.sh
    ./setup.sh
}
git_install_yay() {
    echo "Installing > https://aur.archlinux.org/yay.git"
    cd ~
    if [ -d "yay" ]; then
        rm -rf "yay"
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay --version
}

manual() {
    echo -e ${BBlue}"\n[*] Manual update is starting..." ${Color_Off}
    repo_pull

    # configuration files
    cu

    # make files executable
    ex

    # sysZ / config.json
    read -p "
    Copy default sysZ config file?
    " choice
    if [ "$choice" = "y" ]; then
        if [ -f "conf/config.json" ]; then
            mkdir -p "/home/$(whoami)/.config/sysZ/"
            cp "/home/$(whoami)/sysZ/conf/config.json" "/home/$(whoami)/.config/sysZ/"
            echo "sysZ config copied successfully"
        else
            echo "sysZ config file dose not exist"
        fi
    else
        echo "config.json was not replaced"
    fi

    echo "Scanning for changes in default applications"

    # install yay
    read -p "
    Install yay?
    (y/n): " choice

    if [ "$choice" = "y" ]; then
        git_install_yay
    fi

    # rofi
    read -p "
    [CAUTION]: rofi will not function correctly without this due to how the current configuration is setup
    Check if themes are installed? (if not, install them)
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_rofi
    else
        echo "CAUTION: super + d may not work/function correctly"
    fi

    # packages & update
    read -p "
    (y) Install yay packages
    (p) Install pacman packages
    (b) Install both packages
    (u) System Update
    " choice

    if [ "$choice" = "y" ]; then
        sh /home/$(whoami)/sysZ/shell/yay.sh
    elif [ "$choice" = "p" ]; then
        sh /home/$(whoami)/sysZ/shell/pacman.sh
    elif [ "$choice" = "b" ]; then
        sh /home/$(whoami)/sysZ/shell/yay.sh
        sh /home/$(whoami)/sysZ/shell/pacman.sh
    elif [ "$choice" = "u" ]; then
        sudo pacman -Syu
    else
        echo "Skipping..."
    fi

    # render lockscreen
    echo "Rendering lockscreen"
    betterlockscreen -u $sysZ/bg

    # end
    # echo "===> All done! :)"
    echo -e ${BGreen}"[*] Setup has finished\n" ${Color_Off}
    cd "$current_dir"
}

check_updates() {
    current_dir=$(pwd)
    cd "/home/$(whoami)/sysZ"

    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git remote update >/dev/null 2>&1
        if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
            python /home/$(whoami)/sysZ/main.py update_confirmation
        else
            echo "No updates available."
        fi
    fi
}

# PACMAN & AUR INSTALL FUNCTIONS >

install_rec_pacman() {
    not_installed=0
    key="Arch"
    echo "Checking $key"
    echo -e ${BRed}"[*] Attention Required\n" ${Color_Off}
    for package in "${pacman_packages[@]}"; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            sudo pacman -S --noconfirm "$package"
            not_installed=1
        fi
    done
    if [ $not_installed -eq 1 ]; then
        echo "Some $key packages were installed."
    else
        echo "$key packages are already installed."
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
        echo "$key packages are already installed."
    fi
}

automatic_setup_func() {
    echo -e ${BGreen}"[*] Automatic Setup is starting...\n" ${Color_Off}
    repo_pull
    cu
    install_rec_yay
    install_rec_pacman
    echo "Rendering lockscreen"
    betterlockscreen -u /home/$(whoami)/sysZ/bg
    cd "$current_dir"
}

wm_setup_func() {
    killall -9 polybar copyq
    echo -e ${BBlue}"\n[*] Setup is starting..." ${Color_Off}
    i3-msg "exec feh --bg-fill $sysZ/bg;"
    i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"
    i3-msg "exec sh $sysZ/shell/pull.sh --update-check;"
    i3-msg "exec copyq;"
    i3-msg "exec sox $sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
    i3-msg "reload"
    if checkJson "use_background_blur"; then
        i3-msg 'exec killall -9 autotiling; workspace 9; exec alacritty -e autotiling;'
    fi
    echo -e "${BRed}[!] Please manually refresh (CTRL+SHIFT+R)\n${Color_Off}"
    read -p "Press [Enter] to continue..."
}

function trap_ctrlc() {
    echo -e ${BRed}"[!] The current operation has been stopped.\n" ${Color_Off}
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

# ----------------------------- Flag Logic

if [ "$1" = "--h" ]; then
    echo "Available flags:"
    echo "--automatic    : Checks repository for updates & automatically installs them"
    echo "--root         : Manual setup with root privileges"
    echo "--pacman       : Installs recommended Arch Linux packages"
    echo "--yay          : Installs recommended Arch User Repository packages"
    echo "--setup        : Reloads sysZ's integration of the window manager"
    echo "--update-check : Checks for repository updates. Returns true or false (dose not update anything)"
    echo -e ${BGreen}"   : \nRecommended flags\n" ${Color_Off}
    echo "--first-setup  : Runs the first time setup installer (customization)"
    echo "--automatic    : Updates sysZ & updates arch linux & installs any new recommended packages"
    echo "--update-sysZ  : Updates sysZ"
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
    --root)
        run_as_root=true
        valid_flag=true
        ;;
    --pacman)
        install_pacman=true
        valid_flag=true
        ;;
    --yay)
        install_yay=true
        valid_flag=true
        ;;
    --setup)
        wm_setup=true
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
    --automatic)
        automatic=true
        valid_flag=true
        ;;
    --update-sysZ)
        update_sysZ=true
        valid_flag=true
        ;;
    *)
        # Handle other arguments as needed
        ;;
    esac
done

echo -e ${BPurple}"[*] sysZ\n" ${Color_Off}

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
    repo_pull
    wm_setup_func

else
    manual
fi
