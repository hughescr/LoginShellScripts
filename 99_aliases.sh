alias cls='clear'
alias mroe='more'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi
alias ls="ls -Fa ${colorflag}"

#alias sed='/sw/bin/gsed'
alias top='top -R -s 2 -n30'
alias decolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'

# Allow aliases to be sudo'd
alias sudo='sudo '
