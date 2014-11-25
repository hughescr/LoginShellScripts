if [ -x /usr/local/bin/brew ]; then
    # Remove /usr/local/bin from existing PATH and move it up to the front
    export PATH="/usr/local/sbin:/usr/local/bin:${PATH/:\/usr\/local\/bin/}"
    export MANPATH="/usr/local/share/man:$MANPATH"
fi
