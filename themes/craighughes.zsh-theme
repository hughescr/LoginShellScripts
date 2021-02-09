ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[cyan]%}%{+%G%}"

PROMPT='%f%k$(git_super_status)[%n@%m:%5~]%(!.#.$) '

RPROMPT='$(aws_prompt_info) %(?,%F{034}[√],%F{160}[$?])%F{033}[!%!]%f%k'
