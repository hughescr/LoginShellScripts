if type brew &>/dev/null && [ -d "$(brew --prefix)/share/zsh-syntax-highlighting" ]; then
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
