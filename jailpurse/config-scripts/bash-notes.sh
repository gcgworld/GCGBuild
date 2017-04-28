#!/bin/bash

## Bash config
## Configuration allows you to share a set of aliases
## among all users

## Root user is the only one who can modify the base
## for obvious reasons. If another user wants different
## aliases, they can override them in the .bash_rc file
## in their home folder.



## Structure:
	/etc/profile
	/etc/profile.d/bash_completion.sh
	/etc/bash.bashrc
	/etc/.bash_aliases
	/etc/bash_completion 2> . /usr/share/bash-completion/bash-completion

	/etc/skel/.bashrc
	/etc/skel/.bash_logout

	/root/profile
	/root/.bash_aliases
	/root/.bash_history
	/root/.bashrc


	/etc/profile
		sources /etc/bash.bashrc ## System-wide bashrc
			/usr/share/bash-completion/bash_completion is commented out by default
			initiates command-not-found use.
		for i in /etc/profile.d/*.sh
			sources $i
				appmenu-qt5.sh
				bash_completion.sh
				vte.sh
	## Next bash looks for 
	~/.bash_profile
		sources ~/.bashrc
		## that's it for root by default
	~/.bash_login
	~/.profile

	~/.bash_aliases -> /etc/.bash_aliases
	~/.bash_history
	~/.bashrc
