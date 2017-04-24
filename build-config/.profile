~ ~/.profile: executed by Bourne-compatible login shells

PATH=$PATH:/root/jailpurse

if [ "$BASH" ]; then
	if [ -f ~/.bashrc ]; then
		. ~/.bashrc
	fi
fi

mesg n
