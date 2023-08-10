# sysZ
![lock](screenshots/lock.png)
![blank_workspace](screenshots/blank_workspace.png)
![control_panel](screenshots/control_panel.png)
![guide](screenshots/guide.png)
![terminal_help](screenshots/terminal_help.png)

# What is sysZ?
* A preconfigured customization of the  [i3 Window Manager](https://github.com/Airblader/i3)
* The repository is synchronised across three of my computers for one click updating

# Recommended way to install
WARNING! ~ This tool will override many of your configuration files! If you already have `i3-wm` setup it is highly recommended that you back up your existing `.config` folder. 
1. Download the latest [Arch Linux ISO](https://archlinux.org/download/)
2. Flash your [Arch Linux ISO](https://archlinux.org/download/) to a bootable USB flash drive. If you are on windows, you can use this [tool](https://rufus.ie/en/)
3. Boot into the live installation media and when Arch Linux boots up, synchronise mirrors (sudo pacman -Sy) then run [archinstall](https://github.com/archlinux/archinstall)
4. While using the [archinstall](https://github.com/archlinux/archinstall) script, select the `i3 window manager` in the `Profile(desktop` section.
5. Once Arch Linux has been setup, login to a user account and open a terminal ($mod+enter). In the terminal, run `sudo pacman -S git` and from the home directory, run `git clone https://github.com/AnAncientForce/sysZ.git`
6. Once cloned, `cd` into the `~/sysZ/shell` folder
7. Run `sh pull.sh --first-setup`, you will be asked a few questions about what you would like to be installed. The [required] options are necessary otherwise things may not function as expected.
8.  Once complete, re-open your terminal and run `sysZ -u` and confirm that it is working. Once done you can reboot.

# How to use
In a terminal, running `sysz -h` will display a list of help commands. Alternatively you can open the control panel (by clicking the cube icon in the polybar) if you prefer a gui interface.

# Dependencies
- [i3-gaps](https://github.com/Airblader/i3)
- [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen)
- [polybar](https://github.com/jaagr/polybar)
- [FontAwesome](https://github.com/FortAwesome/Font-Awesome)
- [You can see the full list here](https://github.com/AnAncientForce/sysZ/blob/main/shell/pull.sh)
