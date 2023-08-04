#!/bin/bash
sysZ=""
if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi
rm -f "$sysZ/shell/pull.sh"
git pull
chmod +x pull.sh
cd $sysZ/shell
