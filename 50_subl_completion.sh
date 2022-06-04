if [ -n "$ZSH" ]; then
	# When using sublime plugin the command gets confused with ' escaping and has a ' on the end
	# When just straight aliasing, it does not
	zstyle ':completion:*:*:subl'\'':*:*' ignored-patterns '*.sublime-workspace'
	zstyle ':completion:*:*:subl:*:*' ignored-patterns '*.sublime-workspace'
else
	complete -f -X '*.sublime-workspace' -o filenames subl
fi
