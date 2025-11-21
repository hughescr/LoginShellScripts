alias codex='/opt/homebrew/bin/bunx @openai/codex --search'

# make completion look through aliases
setopt COMPLETE_ALIASES

# load zsh completion system (OMZ usually already did this; safe if repeated)
autoload -U compinit && compinit -u

# install Codex’s function
eval "$(codex completion zsh)"

compdef _codex codex=codex
