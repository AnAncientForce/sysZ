#!/bin/bash
sysZ=""
if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi
if [ -f "$sysZ/shell/pull.sh" ]; then
    rm "$sysZ/shell/pull.sh"
fi
git pull
chmod +x pull.sh
cd $sysZ/shell
