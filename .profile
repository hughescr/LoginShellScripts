shopt -s extglob

if [[ -d "$HOME/.bashd"  && -r "$HOME/.bashd" && -x "$HOME/.bashd" ]]; then
	for i in $(LC_ALL=C command ls "$HOME/.bashd"); do
		[[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)|Makefile*) && -f "$HOME/.bashd/$i" && -r "$HOME/.bashd/$i" ]] && . "$HOME/.bashd/$i"
	done
fi
