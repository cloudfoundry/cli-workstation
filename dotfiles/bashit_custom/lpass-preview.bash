lpass-preview() {
	lpass status && lpass ls \
		| fzf --preview="echo {} | cut -d: -f2 | sed 's/\]//' | xargs lpass show"
}
