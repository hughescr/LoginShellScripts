if [ -x /usr/local/bin/brew ]; then
    # Coreutils
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

    # GNU tar
    export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

    # GNU sed
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi
