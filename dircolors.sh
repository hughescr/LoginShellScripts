if [ -x /usr/local/bin/vivid ] || [ -x /opt/homebrew/bin/vivid ]; then
    export LS_COLORS="$(vivid generate snazzy)"
else
    dircolors > /dev/null 2>&1 && eval "$(dircolors "$HOME/.dircolors")"
fi
