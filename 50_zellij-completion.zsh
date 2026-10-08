# load zsh completion system (OMZ usually already did this; safe if repeated)
autoload -U compinit && compinit -u

if command -v zellij >/dev/null 2>&1; then
    eval "$(zellij setup --generate-completion zsh)"
fi
