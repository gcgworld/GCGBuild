#!/bin/bash

OIFS=$IFS
IFS=":::"

cur_pid="$$"
config_scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_files_dir="$config_scripts_dir/config-files"


parse_args() {
	read -r -a instruction <<< $conf_line

	case "${instruction[0]}" in
		ainst)
			action='apt-get install -y "${instruction[1]}"'
			;;
		apurge)
			action='apt-get purge -y "${instruction[1]}"'			
			;;
		dinst)
			deb_pkg="$(find . -name '*"${instruction[1]}"*' -exec echo "{}" \;)"
			action='dpkg -i "$deb_pkg"'
			unset deb_pkg
			;;
		dpurge
			action='dpkg -P "${instruction[1]}"'
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
	for conf_line in $(cat $pkg_list)
	do
		parse_args
		execute_action
	done
	unset conf_line
	echo "The requested packages have been removed."
}

iter_through_pkg_lists() {
	pkg_lists=( )
	for pkg_list in $(find . -name "pkg-*.conf" -exec echo "{}" \;)
	do
		pkg_lists[${#pkg_lists[*]}]="$pkg_list"
		read_pkg_list
	done
	unset pkg_list
	echo "${pkg_lists[@]}"
}

iter_through_pkg_lists

# clean_debris() {

# }

# package_verification() {

# }

# source_verification() {

# }

# source_build() {

# }

# source_install() {
	
# }
IFS=$OIFS