set -o emacs

# Terminal colours - must use %{ and %} (zsh) or \[ and \] (bash) to tell readline about them, so zsh line editing works
if [ -n "$ZSH_VERSION" ]; then
    # Zsh: Use %{ and %} to enclose non-printing sequences
    npr_start='%{'
    npr_end='%}'
elif [ -n "$BASH_VERSION" ]; then
    # Bash: Use \[ and \] to enclose non-printing sequences
    npr_start='\['
    npr_end='\]'
else
    # Default to Bash-style if the shell is not detected
    npr_start='\['
    npr_end='\]'
fi

inverse="${npr_start}$(tput smso)${npr_end}"
uninverse="${npr_start}$(tput rmso)${npr_end}"
bold="${npr_start}$(tput bold)${npr_end}"
unbold="${npr_start}$(tput dim)${npr_end}"
reset="${npr_start}$(tput sgr0)${npr_end}"
black="${npr_start}$(tput setaf 0)${npr_end}"
red="${npr_start}$(tput setaf 1)${npr_end}"
green="${npr_start}$(tput setaf 2)${npr_end}"
blue="${npr_start}$(tput setaf 4)${npr_end}"
magenta="${npr_start}$(tput setaf 5)${npr_end}"
yellow="${npr_start}$(tput setaf 3)${npr_end}"
cyan="${npr_start}$(tput setaf 6)${npr_end}"

function _git_prompt() {
    local git_status
    git_status="$(git status -unormal 2>&1)"
	if ! [[ "$git_status" =~ (Not\ a\ git\ repo|not\ a\ git\ repository) ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi="$inverse$bold$green"
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi="$inverse$bold$yellow"
        else
            local ansi="$inverse$bold$red"
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=''
            branch="$branch $(git describe --tags --dirty --always)"
        elif [[ "$git_status" =~ HEAD\ detached\ (from|at)\ ([^[:space:]]+) ]]; then
            branch="tag:${BASH_REMATCH[2]}"
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="($(git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD))"
        fi
        echo -n "${ansi}${branch}${reset} "
    fi
}

# Each shell will have its own wakatime tracking file to lock so only one wakatime process will run at a time per shell (debouncing)
WAKATIME_LOCKFILE=$(mktemp -d)

function _prompt_command() {
    PS1="$(_git_prompt)""[\u@\h:\w]\$ "
    [[ -x /usr/local/bin/wakatime && -x /usr/local/bin/lockrun ]] && (/usr/local/bin/lockrun --quiet --lockfile="${WAKATIME_LOCKFILE}/wakatime.lck" -- /usr/local/bin/wakatime --entity-type app --entity "${PWD}" --alternate-project Terminal --alternate-language Directory &)
}

PROMPT_COMMAND="_prompt_command;$PROMPT_COMMAND"

