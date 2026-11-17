#
# ~/.bashrc
#

# Environment, for every bash that reads this: login shells (through
# ~/.bash_profile), `bash -lc` and interactive shells. ssh commands and
# systemd units don't read it. Nothing above the interactive check may print,
# or scp and rsync break. Values a command passes in win.
for d in "$HOME/.cargo/bin" "$HOME/.local/bin"; do
	case ":$PATH:" in
	*":$d:"*) ;;
	*) PATH="$d${PATH:+:$PATH}" ;;
	esac
done
unset d
export PATH
export GOPATH="${GOPATH:-$HOME/.local/share/go}"
export GOBIN="${GOBIN:-$HOME/.local/bin}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# The rest is for interactive shells only.
[[ $- != *i* ]] && return

# History: large, dated, and in its own file, so a bash without these settings
# can't cut it back to 500 lines. A command starting with a space isn't saved,
# and HISTIGNORE catches the usual secrets if you forget; still, prefer
# `read -rs VAR` for secrets, since history doesn't hide them from ps.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
[[ -d ${HISTFILE%/*} ]] || mkdir -p "${HISTFILE%/*}"
HISTSIZE=100000
HISTFILESIZE=100000
HISTTIMEFORMAT='%F %T '
HISTCONTROL=ignoreboth
HISTIGNORE='*bw unlock*:*BW_SESSION=*:*TOKEN=*:*SECRET=*:*PASSWORD=*'
shopt -s histappend
# PROMPT_COMMAND is an array (/etc/bash.bashrc sets the terminal title in it).
[[ " ${PROMPT_COMMAND[*]} " == *" history -a "* ]] || PROMPT_COMMAND+=('history -a')

# Alias
if [ -f ~/.alias ]; then
	. ~/.alias
fi

# fzf: Ctrl-R history, Ctrl-T files, Alt-C directories. /etc/bash.bashrc has
# already loaded bash-completion, which fzf's completion builds on.
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

# Shown when you arrive somewhere: a new terminal (stream's terminal key starts
# tmux with FASTFETCH=1, which only its first pane gets) or an ssh login.
# Anywhere else, `ff`.
if [[ -n $FASTFETCH || ( -n $SSH_TTY && -z $TMUX && $SHLVL == 1 ) ]]; then
	fastfetch
fi
if [[ -n $FASTFETCH ]]; then
	[[ -n $TMUX ]] && tmux set-environment -u FASTFETCH
	unset FASTFETCH
fi
