#!/bin/bash

OIFS=$IFS
IFS=":::"

cur_pid="$$"
config_scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_files_dir="$config_scripts_dir/config-files"
echo "$config_scripts_dir"
echo "$config_file_dir"
pkgs_to_remove="./config-files/pkg-remove.conf"


parse_args() {
	read -r -a instruction <<< $conf_line
	case "${instruction[0]}" in
		apurge)
			action='apt-get purge -y "${instruction[1]}"'			
			;;
		dpurge
			action='dpkg -P "${instruction[0]}"'
			;;
		force)
			action='dpkg -P --force-depends "${instruction[1]}"'
			;;
	esac
}

execute_action() {
	$action
	unset action
}

read_pkg_list() {
	for conf_line in $(cat $pkgs_to_remove)
	do
		parse_args
		execute_action
	done
	echo "The requested packages have been removed."
}



# add_package() {

# }


# remove() {

# }

# clean_debris() {

# }

IFS=$OIFS