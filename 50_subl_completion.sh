if [ -n "$ZSH" ]; then
	autoload bashcompinit
	bashcompinit
fi
complete -f -X '*.sublime-workspace' -o filenames subl
