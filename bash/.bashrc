#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR=nvim

# Alias
if [ -f ~/.alias ]; then
	. ~/.alias
fi

# FZF Integration (if installed)
if [ -f /usr/share/fzf/key-bindings.bash ]; then
	source /usr/share/fzf/key-bindings.bash
fi
if [ -f /usr/share/fzf/completion.bash ]; then
	source /usr/share/fzf/completion.bash
fi

# Prompt
# Default: PS1='[\u@\h \W]\$ '
PRIMARY_COLOR=$'\e[1;35m'
SEPARATOR_COLOR=$'\e[1;36m'
CLR=$'\e[m'
PS1="\[${SEPARATOR_COLOR}\][\[${CLR}${PRIMARY_COLOR}\]\u\[${CLR}${SEPARATOR_COLOR}\]@\[${CLR}${PRIMARY_COLOR}\]\h \W\[${CLR}${SEPARATOR_COLOR}\]]\[${CLR}${PRIMARY_COLOR}\]\$\[${CLR}\] "

# Fetch
fastfetch --logo-color-1 magenta --logo-color-2 magenta --color magenta --color-separator cyan

# Vim Mode
#set -o vi
#bind 'set show-mode-in-prompt on'
##bind 'set vi-ins-mode-string "+"'
#bind 'set vi-ins-mode-string ""'
#bind 'set vi-cmd-mode-string ":"'

# Host-specific overrides (e.g. device colors, local paths, vi-mode)
if [ -f ~/.bashrc.local ]; then
	. ~/.bashrc.local
fi
