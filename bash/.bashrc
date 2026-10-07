#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"
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
# PRIMARY_COLOR=$'\e[1;35m'
# SEPARATOR_COLOR=$'\e[1;36m'
PRIMARY_COLOR=$'\e[1;36m'
SEPARATOR_COLOR=$'\e[1;33m'
CLR=$'\e[m'
PS1="\[${SEPARATOR_COLOR}\][\[${CLR}${PRIMARY_COLOR}\]\u\[${CLR}${SEPARATOR_COLOR}\]@\[${CLR}${PRIMARY_COLOR}\]\h \W\[${CLR}${SEPARATOR_COLOR}\]]\[${CLR}${PRIMARY_COLOR}\]\$\[${CLR}\] "

# Fetch
fastfetch

# Host-specific overrides (e.g. device colors, local paths)
if [ -f ~/.bashrc.local ]; then
	. ~/.bashrc.local
fi
