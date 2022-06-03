command -v fasd &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "You must install fasd before you can use this plugin"
	echo -e "See: https://github.com/clvv/fasd"
else
	eval "$(fasd --init auto)"
fi
