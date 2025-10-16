# only proceed if docker is installed
if command -v docker >/dev/null 2>&1; then
  # load Docker’s completions
  eval "$(docker completion zsh)"
fi
