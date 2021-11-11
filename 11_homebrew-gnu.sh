if [ -n "${HOMEBREW_PREFIX}" ]; then
    # Coreutils
    export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnuman:$MANPATH"

    # GNU tar
    export PATH="${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin:$PATH"

    # GNU sed
    export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
    export MANPATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi
