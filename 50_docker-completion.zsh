# only proceed if docker is installed
if command -v docker >/dev/null 2>&1; then
  # ensure the zsh completion system is loaded (you can omit this if your ~/.zshrc already does it)
  autoload -U compinit && compinit

  # load Docker’s completions
  source <(docker completion zsh)
fi
