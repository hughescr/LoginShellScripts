export HISTSIZE=500000
export SAVEHIST=$HISTSIZE

setopt extended_history
setopt incappendhistory
unsetopt sharehistory

setopt hist_fcntl_lock
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

hgrep () { fc -Dlim "*$@*" 1 }
