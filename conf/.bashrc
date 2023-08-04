#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
# neofetch --color_blocks off
alias sysz="$HOME/sysZ/shell/pull.sh"
eval "$(starship init bash)"
