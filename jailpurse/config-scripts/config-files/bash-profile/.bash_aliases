alias l='ls -lia'
alias lr='ls -liaR'
alias img='gpicview'
alias conxns='netstat -planut'
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

