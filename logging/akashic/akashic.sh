#!/bin/bash

## Git Logging Wrapper.

target_file=$1
project_root="/root/dir/of/project"
_text_editor="vim"

init_akashic_record() {
	cd $project_root
	git init && git add -A && git commit -am "Record initial state." && cd -
}

edit_target_file() {
	target_file_init="$(dirname "$target_file")"./__$target_file.init
	cp "$target_file" "$target_file_init"
	$_text_editor "$target_file"
	if [ "$(diff -s $target_file $target_file_init | grep -oP "\w+$")" == "identical" ]; then
		exit
	elif [ "$(diff -s $target_file $target_file_init | grep -oP "\w+$")" == "differ" ]; then
		git add $target_file && git commit -am "changed $target_file"
		rm $target_file_init
		exit
	else
		echo "Something's up. Akashic thinks you should investigate this manually."
		exit
	fi
}

## Run that shit
if [ -d "$project_root/.git" ]; then
	edit_target_file
else
	if [ "$project_root" == "/root/dir/of/project" ]; then
		echo "Where is the root folder of the project? "
		read project_root
		echo "Initializing git repo in $project_root."
		if [ -d "$project_root/.git" ]; then
			edit_target_file
		else
			init_akashic_record &&
			echo "Git repo initialized. Opening editor."
		fi
	else
		init_akashic_record &&
		echo "Git repo initialized. Opening editor."
	fi
	edit_target_file
fi

