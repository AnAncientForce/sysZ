#!/bin/bash

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
    if [ -f "$json_file" ]; then
        value=$(jq -r ".$1" "$json_file")
        if [ "$value" = "true" ]; then
            return 0
        else
            return 1
        fi
    else
        echo "JSON file not found: $json_file"
        return 2
    fi
}

if ! checkJson "ignore_updates"; then
    current_dir=$(pwd)
    cd $sysZ

    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git remote update >/dev/null 2>&1
        if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
            echo "sysZ "
            dunstify -t 10000 "An update is now available for sysZ"
        else
            echo ""
            # echo "sysZ "
        fi
    fi
fi
