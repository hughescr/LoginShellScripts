if [ -n "$ZSH" ]; then
	zstyle ':completion:*:*:subl'\'':*:*' ignored-patterns '*.sublime-workspace'
else
	complete -f -X '*.sublime-workspace' -o filenames subl
fi
