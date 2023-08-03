#!/bin/sh

DIALOG_RESULT=$(echo -e 'librewolf\nchromium\ncava\nthunar\nlibreoffice\npavucontrol\nlibreoffice\nkitty\nalacritty\ngparted' | rofi -dmenu -i -p "Favorite [ GUI ] : " -hide-scrollbar -tokenize -lines 9 -eh 1 -width 40 -location 8 -xoffset 170 -yoffset 70 -padding 30 -disable-history -font "RobotoMono 18")

echo "This result is : $DIALOG_RESULT"
sleep 1;

if [ "$DIALOG_RESULT" = "librewolf" ];
then
    exec librewolf

elif [ "$DIALOG_RESULT" = "chromium" ];
then
    exec teamspeak3

elif [ "$DIALOG_RESULT" = "cava" ];
then
    exec cava

elif [ "$DIALOG_RESULT" = "thunar" ];
then
    exec thunar

elif [ "$DIALOG_RESULT" = "libreoffice" ];
then
    exec libreoffice

elif [ "$DIALOG_RESULT" = "pavucontrol" ];
then
    exec pavucontrol

elif [ "$DIALOG_RESULT" = "kitty" ];
then
    exec kitty

elif [ "$DIALOG_RESULT" = "alacritty" ];
then
    exec alacritty

elif [ "$DIALOG_RESULT" = "gparted" ];
then
    exec gksudo gparted
fi