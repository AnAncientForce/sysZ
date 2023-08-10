# sysZ
* My implementation of a custom version of the i3 window manager using Arch Linux
* The repository is synchronised across three of my computers for one click updating

# Dependencies
- [i3-gaps](https://github.com/Airblader/i3)
- [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen)
- [polybar](https://github.com/jaagr/polybar)
- [FontAwesome](https://github.com/FortAwesome/Font-Awesome)
- xfce4-screenshooter
- neofetch
- [Many many more](https://github.com/AnAncientForce/sysZ/blob/main/shell/pull.sh)

# Recommended way to install
1. Download the latest [Arch Linux ISO](https://archlinux.org/download/)
2. Flash your [Arch Linux ISO](https://archlinux.org/download/) to a bootable USB flash drive. If you are on windows, you can use this [tool](https://rufus.ie/en/)
3. Boot into the live installation media and when Arch Linux boots up, synchronise mirrors (sudo pacman -Sy) then run [archinstall](https://github.com/archlinux/archinstall)
4. Once Arch Linux has been setup, login to a user account and run `sudo pacman -S git` and from the home directory, run `git clone https://github.com/AnAncientForce/sysZ.git`
5. Once cloned, `cd` into the `~/sysZ/shell` folder
6. Run `sh pull.sh --first-setup`, you will be asked a few questions about what you would like to be installed. The [required] options are necessary otherwise things may not function as expected.
7.  Once complete, re-open your terminal and run `sysZ -u` and confirm that it is working. Once done you can reboot.
8.  Setup complete
