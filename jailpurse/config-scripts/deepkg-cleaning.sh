#!/bin/bash

OIFS=$IFS
IFS=":"

cur_pid="$$"
config_scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_files_dir="$config_scripts_dir/config-files"
echo "$config_scripts_dir"
echo "$config_file_dir"
pkgs_to_remove="./config-files/pkg-remove.conf"


parse_args() {
	read -r -a instruction <<< $conf_line
	if [ "${instruction[0]}" == "purge" ]; then
		action="apt-get ${instruction[0]} -y ${instruction[1]}"
}

read_pkg_list() {
	for conf_line in $(cat $pkgs_to_remove)
	do
		parse_args	
	done
}



# add_package() {

# }


# remove() {

# }

# clean_debris() {

# }

IFS=$OIFS