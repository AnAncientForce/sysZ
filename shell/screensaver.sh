#!/usr/env/bin bash
# Created by Z : Screen saver script

#BASEDIR=$(dirname $0)
#path=~/sysZ/videos/
#total=$(find $path* -name "*.mp4" | wc -l)
#r=$RANDOM
#r=$(($r % $total))

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

lockfile="$temp_dir/screensaver.lock"
if [ -e "$lockfile" ]; then
    echo "Instance is already running. Exiting."
    exit 1
fi
touch "$lockfile"

files=($sysZ/videos/*)
# printf "%s\n" "${files[RANDOM % ${#files[@]}]}"

if pgrep -x "mpv" >/dev/null; then
    killall -9 mpv
    rm -f "$lockfile"
    exit 0
fi

# Run
mpv --fs --loop --mute -no-osc --no-osd-bar "${files[RANDOM % ${#files[@]}]}" &

# Check when activity is back
# Compare mouse position
while true; do
    sleep 0.25

    prev=$(xdotool getmouselocation | sed 's/x:\(.*\) y:\(.*\) screen:.*/\1, \2/')

    sleep 0.25

    m=$(xdotool getmouselocation | sed 's/x:\(.*\) y:\(.*\) screen:.*/\1, \2/')
    if [ "$m" = "$prev" ]; then
        echo "same"
    else
        echo "not same!"
        if pgrep -x "mpv" >/dev/null; then
            killall -9 mpv
        # exit 0
        fi
        rm -f "$lockfile"
        exit 0
    fi

done
