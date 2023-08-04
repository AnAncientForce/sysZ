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
change_wallpaper=false
view_docs=false
user_home=""
json_file=""
sysZ=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    json_file="/home/$SUDO_USER/.config/sysZ/config.json"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    json_file="/home/$(whoami)/.config/sysZ/config.json"
    user_home="/home/$(whoami)"
fi

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
    echo -e "${BPurple}[*] Updating configuration files${Color_Off}"
    mkdir -p "$user_home/.config/kitty"
    cp "$sysZ/conf/i3" "$user_home/.config/i3/config"
    cp "$sysZ/conf/kitty.conf" "$user_home/.config/kitty"
    cp "$sysZ/conf/alacritty.yml" "$user_home/.config"
    cp "$sysZ/conf/.bashrc" "$user_home"
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
    read -p "Install Yay?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_yay
    fi

    # install starship
    read -p "[Required] Install starship?
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        cd ~
        curl -sS https://starship.rs/install.sh | sh
    fi

    # rofi
    read -p "[CAUTION]: rofi will not function correctly without this due to how the current configuration is setup
    Check if themes are installed? (if not, install them)
    (y/n): " choice
    if [ "$choice" = "y" ]; then
        git_install_rofi
    else
        echo "CAUTION: super + d may not work/function correctly (if not installed)"
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

    # render lockscreen
    continue_setup_func

    # end
    # echo "===> All done! :)"
    # echo -e ${BGreen}"[*] Setup has finished\n" ${Color_Off}
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

change_wallpaper_func() {
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

automatic_setup_func() {
    echo -e ${BGreen}"[*] Automatic Setup is starting...\n" ${Color_Off}
    repo_pull
    cu
    install_rec_yay
    install_rec_pacman
    continue_setup_func
    cd "$current_dir"
}

continue_setup_func() {
    echo -e "${BPurple}[*] Rendering lockscreen...${Color_Off}"
    betterlockscreen -u $sysZ/bg
}

view_docs_func() {
    if [ -z "$2" ]; then
        echo -e "${BRed}\n[!] Please provide a valid [doc] name.\n${Color_Off}"
        exit 2
    fi
    doc_name="$2"
    case "$doc_name" in
    "bluetooth")
        cat "$sysZ/docs/bluetooth.txt"
        ;;
    "i3")
        cat "$sysZ/docs/i3.txt"
        ;;
    "pkgs")
        cat "$sysZ/docs/pkgs.txt"
        ;;
    "print")
        cat "$sysZ/docs/print.txt"
        ;;
    *)
        echo -e "${BRed}\n[!] Invalid document\n${Color_Off}"
        echo -e ${BGreen}"[*] --docs        : View docs: [bluetooth, i3, pkgs, print]" ${Color_Off}
        exit 2
        ;;
    esac
    exit 0
}

wm_setup_func() {
    killall -9 polybar copyq
    echo -e ${BBlue}"\n[*] wm-refresh" ${Color_Off}
    i3-msg "exec feh --bg-fill $sysZ/bg;"
    i3-msg "exec polybar -c $sysZ/conf/polybar.ini;"
    i3-msg "exec copyq;"
    i3-msg "exec sox $sysZ/sfx/Sys_Camera_SavePicture.flac -d;"
    i3-msg "reload"
    if checkJson "use_background_blur"; then
        i3-msg 'exec killall -9 autotiling; workspace 9; exec alacritty -e autotiling;'
    fi
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

echo -e ${BPurple}"[*] sysZ\n" ${Color_Off}
if [ "$1" = "-h" ]; then
    echo -e ${BPurple}"\nAvailable flags\n" ${Color_Off}
    echo -e ${BGreen}"[*] -h            : Lists all available flags" ${Color_Off}
    echo -e ${BGreen}"[*] --first-setup : Runs the first time setup installer" ${Color_Off}
    echo -e ${BGreen}"[*] --automatic   : Updates sysZ & updates arch linux & installs any new recommended packages" ${Color_Off}
    echo -e ${BGreen}"[*] --update-sysZ : Updates sysZ" ${Color_Off}
    echo -e ${BGreen}"[*] --root        : Runs the first time [root] setup installer" ${Color_Off}
    echo -e ${BGreen}"[*] --cw          : Change Wallpaper" ${Color_Off}
    echo -e ${BGreen}"[*] --ca          : Change Appearance" ${Color_Off}
    echo -e ${BGreen}"[*] -l            : Lock Workstation" ${Color_Off}
    echo -e ${BGreen}"[*] --docs        : View docs: [bluetooth, i3, pkgs, print]" ${Color_Off}
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
    --cw)
        change_wallpaper=true
        valid_flag=true
        ;;
    --cd)
        cd "$sysZ/shell"
        echo -e ${BGreen}"\nDirectory Changed\n" ${Color_Off}
        exit 0
        ;;
    --ca)
        i3-msg 'exec qt5ct; exec lxappearance;'
        exit 0
        ;;
    -l)
        i3-msg 'exec betterlockscreen -l;'
        exit 0
        ;;
    --docs)
        view_docs=true
        valid_flag=true
        ;;
    *)
        # Handle other arguments as needed
        ;;
    esac
done
if ! $valid_flag; then
    echo -e ${BRed}"\n[!] Incorrect or misspelled flag.\n\nProceeding with default...\n" ${Color_Off}
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
    repo_pull
    cu
    ex
    wm_setup_func

elif [ "$change_wallpaper" = true ]; then
    change_wallpaper_func

elif [ "$view_docs" = true ]; then
    view_docs_func "$@"

else
    manual
fi
echo -e ${BGreen}"[*] Setup has finished\n" ${Color_Off}
