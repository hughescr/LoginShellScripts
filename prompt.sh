set -o emacs

# Terminal colours - must use \[ and \] to tell readline about them, so bash line editing works
inverse="\[$(tput smso)\]"
uninverse="\[$(tput rmso)\]"
bold="\[$(tput bold)\]"
unbold="\[$(tput dim)\]"
reset="\[$(tput sgr0)\]"
black="\[$(tput setaf 0)\]"
red="\[$(tput setaf 1)\]"
green="\[$(tput setaf 2)\]"
blue="\[$(tput setaf 4)\]"
magenta="\[$(tput setaf 5)\]"
yellow="\[$(tput setaf 3)\]"
cyan="\[$(tput setaf 6)\]"

function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
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
            branch="$branch `git describe --tags --dirty --always`"
		elif [[ "$git_status" =~ HEAD\ detached\ (from|at)\ ([^[:space:]]+) ]]; then
			branch="tag:${BASH_REMATCH[2]}"
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n "${ansi}${branch}${reset} "
    fi
}
function _prompt_command() {
    PS1="`_git_prompt`""[\u@\h:\w]\$ "
}
PROMPT_COMMAND="_prompt_command;$PROMPT_COMMAND"
