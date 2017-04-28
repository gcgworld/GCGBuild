#!/bin/bash

## Jack a dpkg package from another distro.

for pkg in $(dpkg --list | grep -oP 'ii\s+(\w+|\-|\:|\d+|\.)+' | grep -oP '\S+$')
do
	target_dir="$(pwd)/the_bedroom/$pkg"
	mkdir -p $target_dir
	for list_item in $(dpkg --listfiles "$pkg")
	do
		if [ -f $list_item ]; then
			cp --parents $list_item $target_dir 
		fi
	done
	unset target_dir
done
