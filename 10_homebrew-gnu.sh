if [ -x /opt/homebrew/bin/brew ]; then
    BREW_PREFIX=/opt/homebrew
elif [ -x /usr/local/bin/brew ]; then
    BREW_PREFIX=/usr/local
fi

if [ -n "${BREW_PREFIX}" ]; then
    # Coreutils
    export PATH="${BREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="${BREW_PREFIX}/opt/coreutils/libexec/gnuman:$MANPATH"

    # GNU tar
    export PATH="${BREW_PREFIX}/opt/gnu-tar/libexec/gnubin:$PATH"

    # GNU sed
    export PATH="${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
    export MANPATH="${BREW_PREFIX}/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi
