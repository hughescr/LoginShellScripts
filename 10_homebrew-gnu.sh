if [ -x /usr/local/bin/brew ]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi
