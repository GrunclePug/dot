#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR=nano

# Alias
if [ -f ~/.alias ]; then
    . ~/.alias
fi

# Prompt
# Default: PS1='[\u@\h \W]\$ '
PRIMARY_COLOR=$'\e[1;35m'
SEPARATOR_COLOR=$'\e[1;36m'
CLR=$'\e[m'
PS1="\[${SEPARATOR_COLOR}\][\[${CLR}${PRIMARY_COLOR}\]\u\[${CLR}${SEPARATOR_COLOR}\]@\[${CLR}${PRIMARY_COLOR}\]\h \W\[${CLR}${SEPARATOR_COLOR}\]]\[${CLR}${PRIMARY_COLOR}\]\$\[${CLR}\] "

# Transparency
term="$(cat /proc/$PPID/comm)"
if [[ $term = "st" ]]; then
	transset-df "0.72" --id "$WINDOWID" > /dev/null
fi

# Fetch
fastfetch --logo-color-1 magenta --logo-color-2 magenta --color magenta --color-separator cyan
