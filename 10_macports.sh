if [ -d /opt/local ]; then
    export MANPATH=/opt/local/share/man:$MANPATH
    export PATH=/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH
fi
