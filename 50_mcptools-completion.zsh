if command -v mcptools >/dev/null 2>&1; then
    eval "$(mcptools completion zsh)"
    compdef _mcp mcptools
fi
