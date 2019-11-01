function _git_prompt() {
    local git_status
    git_status="$(git status -unormal 2>&1)"
    if ! [[ "$git_status" =~ (Not\ a\ git\ repo|not\ a\ git\ repository) ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi="%F{green}%S"
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi="%F{yellow}%S"
        else
            local ansi="%F{red}%S"
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=" ${match[1]}"
            test "$branch" != master || branch=''
            branch="$branch $(git describe --tags --dirty --always)"
        elif [[ "$git_status" =~ HEAD\ detached\ (from|at)\ ([^[:space:]]+) ]]; then
            branch=" ${match[2]}"
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="($(git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD))"
        fi
        echo -n "${ansi}${branch}%s%f "
    fi
}

PROMPT='%f%k$(_git_prompt)[%n@%m:%5~]%(!.#.$) '

RPROMPT='$(aws_prompt_info) %(?,%F{034}[√],%F{160}[$?])%F{033}[!%!]%f%k'
