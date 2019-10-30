function _git_prompt() {
    local git_status
    git_status="$(git status -unormal 2>&1)"
    if ! [[ "$git_status" =~ (Not\ a\ git\ repo|not\ a\ git\ repository) ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi="%{$bg[green]%}%{$fg[black]%}"
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi="%{$bg[yellow]%}%{$fg[black]%}"
        else
            local ansi="%{$bg[red]%}%{$fg[black]%}"
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${match[1]}
            test "$branch" != master || branch=''
            branch="$branch $(git describe --tags --dirty --always)"
        elif [[ "$git_status" =~ HEAD\ detached\ (from|at)\ ([^[:space:]]+) ]]; then
            branch="tag:${match[2]}"
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="($(git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD))"
        fi
        echo -n "${ansi}${branch}%{$reset_color%} "
    fi
}

PROMPT='%{$reset_color%}$(_git_prompt)[%n@%m:%5~]%# '

RPROMPT='$(aws_prompt_info) %(?,$FG[034][R-$?],$FG[160][$?])$FG[033][!%!]%{$reset_color%}'
