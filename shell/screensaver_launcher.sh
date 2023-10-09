#!/usr/env/bin bash

timeout=120
if [ $# -eq 0 ]; then
    echo "[default timeout: 120]]"
else
    timeout=$1
fi
# let "timeout=$1*1000"

xidlehook --not-when-audio --timer $timeout 'sh ~/sysZ/shell/screensaver.sh &' ''
