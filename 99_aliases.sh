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
    netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
}
