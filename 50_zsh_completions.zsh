if type brew &>/dev/null && [ -d $(brew --prefix)/share/zsh-completions ]; then
    fpath=($(brew --prefix)/share/zsh-completions $fpath)

    autoload -Uz compinit
    compinit
fi
