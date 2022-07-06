if [ -x "/usr/local/bin/op" ]; then
    eval "$(/usr/local/bin/op completion zsh)"; compdef _op op
fi
