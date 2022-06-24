if [ -x /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
elif [ -x /usr/local/bin/brew ]; then
    eval $(/usr/local/bin/brew shellenv)
fi

alias newbrew='(for TAP in $(find ${HOMEBREW_PREFIX}/Library/Taps -type d -name .git); do git --git-dir="${TAP}" changes --no-merges --diff-filter=A --since="2 weeks ago"; done) | fgrep new | cut -d" " -f 5-6 | align -jt'
