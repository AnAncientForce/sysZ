# Anything that requires root perms will be here
# Anything that dose not require room perms will not be here

echo "Root setup has started"
sh pacman.sh

read -p "
Setup dark mode?
(y/n): " choice

if [ "$choice" = "y" ]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script with sudo or as root."
        exit 1
    fi
    echo "Setting up QT_QPA_PLATFORMTHEME in /etc/environment..."
    echo 'QT_QPA_PLATFORMTHEME="qt5ct"' >/etc/environment
    lxappearance &
    qt5ct &
fi

echo "Root setup has finished =D"
