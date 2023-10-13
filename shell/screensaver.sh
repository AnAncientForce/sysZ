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

leave() {
    # killall -9 mpv
    # sh $sysZ/shell/pull.sh --kill-pid "$mpv_pid"
    if [ -n "$mpv_pid" ]; then
        kill "$mpv_pid"
    fi
    rm -f "$lockfile"
    exit 0
}

if [ -e "$lockfile" ]; then
    echo "Instance is already running. Exiting."
    exit 1
fi
if pgrep -x "i3lock" >/dev/null; then
    echo "The screen is locked."
    echo "The screen is locked" >>"${sysZ}/log.txt"
    exit 1
fi
touch "$lockfile"

if pgrep -x "mpv" >/dev/null; then

    playing_mpv_instances=()

    while read -r pid; do
        mpv_status=$(mpv --input-ipc-server=/tmp/mpvsocket-"$pid" --get-property pause 2>/dev/null)

        if [ "$mpv_status" == "no" ]; then
            playing_mpv_instances+=("$pid")
        fi
    done < <(pgrep -x "mpv")

    if [ "${#playing_mpv_instances[@]}" -gt 0 ]; then
        echo "There are active mpv instances playing systemwide."
        leave
    else
        echo "No active mpv instances found playing systemwide."
    fi
else
    echo "No active mpv instances found playing systemwide."
fi

files=($sysZ/videos/*)
# printf "%s\n" "${files[RANDOM % ${#files[@]}]}"

#if pgrep -x "mpv" >/dev/null; then
#    leave
#fi

# Run
mpv --fs --loop --mute -no-osc --no-osd-bar "${files[RANDOM % ${#files[@]}]}" &
mpv_pid=$!
# sh $sysZ/shell/pull.sh --store-pid "$mpv_pid"

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
            leave
        else
            echo "? The mpv was not running. You shouldn't see this... ever" >>"${sysZ}/log.txt"
            leave
        fi
    fi

    cpu_temp=$(sensors | grep "Core 0" | awk '{print $3}' | cut -c 2-3)
    if [ "$cpu_temp" -ge 85 ]; then
        echo "Temperature is dangerously high, so the screensaver was stopped." >>"${sysZ}/log.txt"
        leave
    fi

done
