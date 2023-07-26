#!/bin/sh

x='.*'
FILES=~/sysZ/wallpapers/*
index=0
max=0



# ls ~/Pictures/wallpapers/
function trap_ctrlc ()
{
    feh --bg-fill ~/sysZ/bg.*
    exit 2
}
trap "trap_ctrlc" 2



while true; do
    let "max=0"
    let "index=0"
    for f in $FILES
    do
    let "max=max+1"
    done
    # --------------------------

    for f in $FILES
    do
    echo $f
    let "index=index+1"
    feh --bg-fill $f
    read -p "($index/$max) Set this wallpaper? : " yn
    case $yn in
        [Yy]* )
        echo "The wallpaper $name has been set"
        cp -v $f ~/sysZ/bg
        exit 2
        # v logging
        # f Do not prompt for confirmation before overwriting existing files
        break;;
        [Bb]* )
        echo "nevermind Reversed Index"
        ;;
        [Nn]* ) ;;
        * ) ;; # echo "Please answer y or n";;
    esac
    done



    while true; do
    read -p "Loop through the wallpapers again? : " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n";;
    esac # 'esac' end case statement
    done
done
