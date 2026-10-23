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

# Prompt, in the active theme's accents (~/.config/theme/colors.sh, read in
# a subshell so its names stay out of this shell); without a theme module,
# the terminal's cyan and yellow.
# Default: PS1='[\u@\h \W]\$ '
read -r accent accent2 < <(. ~/.config/theme/colors.sh 2>/dev/null; echo "${accent:-00cdcd} ${accent2:-cdcd00}")
printf -v PRIMARY_COLOR '\e[1;38;2;%d;%d;%dm' "0x${accent:0:2}" "0x${accent:2:2}" "0x${accent:4:2}"
printf -v SEPARATOR_COLOR '\e[1;38;2;%d;%d;%dm' "0x${accent2:0:2}" "0x${accent2:2:2}" "0x${accent2:4:2}"
unset accent accent2
CLR=$'\e[m'
PS1="\[${SEPARATOR_COLOR}\][\[${CLR}${PRIMARY_COLOR}\]\u\[${CLR}${SEPARATOR_COLOR}\]@\[${CLR}${PRIMARY_COLOR}\]\h \W\[${CLR}${SEPARATOR_COLOR}\]]\[${CLR}${PRIMARY_COLOR}\]\$\[${CLR}\] "

# Fetch, in the active theme's colours (read on every run, so a theme switch
# shows without a new shell)
fastfetch() {
	(
		. ~/.config/theme/colors.sh 2>/dev/null
		command fastfetch ${accent:+--color-keys "#$accent" --color-title "#$accent2" --color-separator "#$line"} "$@"
	)
}
fastfetch

# Host-specific overrides (e.g. device colors, local paths)
if [ -f ~/.bashrc.local ]; then
	. ~/.bashrc.local
fi
