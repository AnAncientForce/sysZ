#!/bin/bash
sysZ=""
if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi
read -p "Delete pull.sh?" choice
if [ "$choice" = "y" ]; then
    rm -f "$sysZ/shell/pull.sh"
fi
git pull
chmod +x $sysZ/pull.sh
cd $sysZ/shell
