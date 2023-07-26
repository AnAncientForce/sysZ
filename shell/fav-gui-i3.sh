#!/bin/sh

applications=("librewolf" "chromium" "cava" "thunar" "libreoffice" "pavucontrol" "kitty" "alacritty" "gparted")

DIALOG_RESULT=$(echo -e "${applications[@]}" | rofi -dmenu -i -p "Favorite [ GUI ] : " -hide-scrollbar -tokenize -lines 9 -eh 1 -width 40 -location 8 -xoffset 170 -yoffset 70 -padding 30 -disable-history -font "RobotoMono 18")

echo "This result is : $DIALOG_RESULT"
sleep 1

case $DIALOG_RESULT in
    "librewolf")
        librewolf
        ;;
    "chromium")
        chromium
        ;;
    "cava")
        cava
        ;;
    "thunar")
        thunar
        ;;
    "libreoffice")
        libreoffice
        ;;
    "pavucontrol")
        pavucontrol
        ;;
    "kitty")
        kitty
        ;;
    "alacritty")
        alacritty
        ;;
    "gparted")
        gksudo gparted
        ;;
esac