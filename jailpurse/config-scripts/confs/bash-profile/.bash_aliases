## Navigation
alias b='cd ..'
alias l='ls -lia'
alias lr='ls -liaR'

## Search & destory
alias f='find .'
alias fall='find /'
alias ff='find . -type f'
alias fdir='find . -type d'
alias fname='find . -name'
alias fperm='find . -perm'
alias fown='find . -user'
alias fgrp='find . -group'
alias fempty='find . -size 0k'
alias flt='find . -size -'
alias fgt='find . -size +'
alias del='shred -zuvn 3'

alias t='gnome-terminal'
alias img='gpicview'
alias conxns='netstat -planut'
alias bigbro='watch -n 2 "netstat -tulpna"'
alias thepids='ps -eo pid'
alias gimme='sudo apt-get install'
alias bounce='sudo apt-get --purge remove'
alias web="python -m SimpleHTTPServer"
alias wificd='wicd-client &>/dev/null &'
alias lsservice='service --status-all'
alias lsinit='initctl --user list && initctl --system list'
alias lssys='sysctl -a'

randport() {
	unset break
	unset number
	while [ "$break" != "0" ]
		do
			number=$(( $RANDOM * 2 ))
			if [ 1040 -lt $number -a $number -lt 65535 ]
				then echo $number
				break=0
			fi
		done
		unset break
		unset number
}

strip_trailing_slash() {
	if [ -z $1 ]; then
		echo "Argument should be a directory."
		exit 1
	else
		$target_dir=$1
		if [ $(echo "${target_dir:((${#target_dir}-1))}") == "/" ]; then
			target_dir="${target_dir:0:((${#target_dir}-1))}"
		else
			return $target_dir
		fi
	fi
	echo $target_dir
	return 0		
}

dupe() {
	if [ -z $1 ]; then
		echo "Usage: dupe [options] /path/to/filename.ext"
		echo "If second argument is not present dupe will
create filename.ext.bkup.gz in the same directory."
		exit 1
	fi
	if [ "$1" == "-c" ]; then
		copy_cmd="gzip -ck"
	else
		copy_cmd="cp"
	fi
		case $1 in
			-c|--compress)
				copy_cmd="gzip -ck"
				shift
				;;
		esac
		if [ -z $1 ];then
			echo "Usage: dupe [options] /path/to/filename.ext"
			echo "Check path to $1 and that it exists."
			return 1
		fi
		if [ -f $1 ]; then
			target_file=$1
			shift
			if [ -z $1 ]; then
				$copy_cmd "$target_file" > "$target_file.bkup.gz"
				return 0
			elif [ -d $1 ]; then
				target_dir=strip_trailing_slash $1
				$copy_cmd "$target_file" > "$target_dir/$(basename "$target_file").bkup.gz"
				return 0
			else
				mkdir -p $target_dir
				if [ -d $1 ]; then	
					$copy_cmd "$target_file" > "$target_dir/$(basename "$target_file").bkup.gz"
					return 0
				else
					echo "Error: could not find or create directory $target_dir"
					return 1
				fi
			fi
		fi
}
