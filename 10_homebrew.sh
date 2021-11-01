if [ -x /opt/homebrew/bin/brew ]; then
    # Add homebrew path to front of PATH if we're in the new /opt/homebrew
    export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:${PATH}"
    export MANPATH="/opt/homebrew/share/man:${MANPATH}"
elif [ -x /usr/local/bin/brew ]; then
    # Remove /usr/local/bin from existing PATH and move it up to the front
    export PATH="/usr/local/sbin:/usr/local/bin:${PATH/:\/usr\/local\/bin/}"
    export MANPATH="/usr/local/share/man:${MANPATH}"
fi
