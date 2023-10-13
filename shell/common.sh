#!/bin/bash
# Github > @AnAncientForce > sysZ

Color_Off='\033[0m'
BBlack='\033[1;30m' BRed='\033[1;31m' BGreen='\033[1;32m' BYellow='\033[1;33m'
BBlue='\033[1;34m' BPurple='\033[1;35m' BCyan='\033[1;36m' BWhite='\033[1;37m'

user_home=""
sysZ=""
temp_dir=""

if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
    user_home="/home/$SUDO_USER"
else
    sysZ="/home/$(whoami)/sysZ"
    user_home="/home/$(whoami)"
fi
temp_dir="$user_home/tmp"

file_exists() {
    if [ -f "$1" ]; then
        echo "File '$1' exists."
    else
        echo "File '$1' does not exist."
    fi
}

function is_package_installed() {
    local package_name="$1"
    yay -Qs "$package_name" &>/dev/null
}

store_pid() {
    local custom_file="$1"
    local pid=$!
    mkdir -p "$(dirname "$custom_file")"
    echo "$pid" >"$custom_file"
}

kill_pid() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if [ -n "$pid" ]; then
            kill -9 "$pid"
            echo "Process with PID $pid has been terminated"
        else
            echo "PID not found in the file $pid_file"
        fi
        # Clean up the PID file
        rm "$pid_file"
    else
        echo "PID file $pid_file not found"
    fi
}

# JSON ================================================================================

saveJson() {
    local key="$1"
    local value="$2"

    # Check if the value is either "true" or "false"
    if [ "$value" = "true" ] || [ "$value" = "false" ]; then
        # Use the already declared $json_file variable to read the JSON content and update the value of the provided key
        jq ".$key = $value" "$json_file" >"$json_file.tmp" && mv "$json_file.tmp" "$json_file"
        echo "JSON value for key '$key' has been set to $value."
    else
        echo "Invalid value provided. Only 'true' or 'false' allowed."
        return 1 # Invalid value
    fi
}

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

checkJsonString() {
    # Check if the file exists
    if [ -f "$json_file" ]; then
        # Use jq to read the JSON content and check if the provided key exists
        if jq -e ". | has(\"$1\")" "$json_file" >/dev/null; then
            # Use jq to retrieve the value of the key and remove surrounding quotes if it's a string
            value=$(jq -r ".$1" "$json_file")
            echo "$value"
            return 0 # Key exists
        else
            return 1 # Key does not exist
        fi
    else
        echo "JSON file not found: $json_file"
        return 2 # File not found
    fi
}
