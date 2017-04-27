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
	/etc/bash_completion.d/
			axi-cache
			cryptdisks
			debconf
			debfoster
			deborphan
			desktop-file-validate
			git-prompt
			grub
			initramfs-tools
			insserv
			ufw
			upstart
	/etc/skel/.bashrc
	/etc/skel/.bash_logout

	/root/profile
	/root/.bash_aliases
	/root/.bash_history
	/root/.bashrc


	/etc/profile
		usually sources some config in /etc/config
		passes control to
	~/.bash_profile
	~/.bash_login
	~/.profile

	~/.bash_aliases -> /etc/.bash_aliases
	~/.bash_history
	~/.bashrc
