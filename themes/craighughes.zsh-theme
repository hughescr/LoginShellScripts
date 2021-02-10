function _craig_git_id() {
    local git_status
    local branch
    git_status="$(git status -unormal 2>&1)"
    if ! [[ "$git_status" =~ (Not\ a\ git\ repo|not\ a\ git\ repository) ]]; then
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=" $(git describe --tags --dirty --always)"
        else
            branch=""
        fi
        echo -n "${branch}"
    fi
}

ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[green]%}%{⚑%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[red]%}%{+%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}%{…%G%}"

PROMPT='%f%k$(ZSH_THEME_GIT_PROMPT_SEPARATOR="$(_craig_git_id)|" git_super_status)[%n@%m:%5~]%(!.#.$) '

RPROMPT='$(aws_prompt_info) %(?,%F{034}[√],%F{160}[$?])%F{033}[!%!]%f%k'
