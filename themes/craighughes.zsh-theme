ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[green]%}%{⚑%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[red]%}%{+%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}%{…%G%}"

PROMPT='%f%k$(git_super_status)[%n@%m:%5~]%(!.#.$) '

RPROMPT='$(aws_prompt_info) %(?,%F{034}[√],%F{160}[$?])%F{033}[!%!]%f%k'
