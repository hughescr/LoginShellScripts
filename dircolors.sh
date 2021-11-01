if [ -x /usr/local/bin/vivid ] || [ -x /opt/homebrew/bin/vivid ]; then
    export LS_COLORS="$(vivid generate snazzy)"
else
    dircolors 2>&1 > /dev/null && eval `dircolors "$HOME/.dircolors"`
fi
