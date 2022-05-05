#!/usr/bin/env bash
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
alias top='top -d -s 2 -o power -O cpu'
alias decolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'

# Allow aliases to be sudo'd
alias sudo='sudo '

# Merge master to develop then push to github with tags
alias hubpush='git checkout develop;git merge master;git push github master develop --follow-tags'

# Command line error fixing
thefuck > /dev/null 2>&1 && eval "$(thefuck --alias)"

# Use helpful defaults for nettop
alias nettop='nettop -cdP -j bytes_in,bytes_out -k interface,state,rx_dupe,rx_ooo,re-tx,rtt_avg,rcvsize,tx_win,tc_class,tc_mgt,cc_algo,P,C,R,W'

# Make xargs check for alias substitution
alias xargs='xargs '
alias xargs0='xargs -0 '

# Image aspect ratio checking to tab-separated output (can be piped to "align -s t+")
alias archeck="identify -format '%[fx:round((w*1000)/h)/1000]	%wx%h	%M\n'"

# Mac function to list TCP ports the machine is listening on since netstat -l doesn't work right
macnst (){
    netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;pos=split($4,chunks,".");addr=$4;sub(/\.[^.]*$/,"",addr);port=chunks[pos]; print "proto: " $1 "|addr: " addr "|port: " port "|pid: " $9 "|name: " procname;  }' | column -t -s "|"
}

# ZSH wants to correct "mocha" to "mosh" -- stop that!
# "yarn test" will try "yarn tests" if there's a directory called "tests"
if [ -n "$ZSH_VERSION" ]; then
	alias mocha='nocorrect mocha'
	alias serverless='nocorrect serverless'
	alias yarn='nocorrect yarn'
fi
