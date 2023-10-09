#!/usr/env/bin bash
# Created by Z : Screen saver script

#BASEDIR=$(dirname $0)
#path=~/sysZ/videos/
#total=$(find $path* -name "*.mp4" | wc -l)
#r=$RANDOM
#r=$(($r % $total))

sysZ=""
if [ "$EUID" -eq 0 ]; then
    sysZ="/home/$SUDO_USER/sysZ"
else
    sysZ="/home/$(whoami)/sysZ"
fi

mp4_folder=$sysz/videos
mp4_files=$(find "$mp4_folder" -type f -name "*.mp4")
random_mp4=$(shuf -n 1 -e $mp4_files)

if pgrep -x "mpv" >/dev/null; then
    killall -9 mpv
    exit 0
fi

# Run
if [ -n "$random_mp4" ]; then
    mpv --fs --loop --mute -no-osc --no-osd-bar $random_mp4 &
fi

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
        exit 0
    fi

done
