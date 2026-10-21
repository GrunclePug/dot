# prof playground: shell of river's quick scratchpad terminal (pg-river-scratch).
# Your normal bash setup, plus: the first command you run marks this terminal
# as used, so Super+Shift+Return swaps it out instead of closing it. The
# marker is written once; ${var=...} keeps PS0 from running it again.
[ -f ~/.bashrc ] && . ~/.bashrc
PS0='${__pg_scratch_used=$(: > "$PG_SCRATCH_DIR/used-$PPID")}'"$PS0"
