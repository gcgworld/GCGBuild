#!/bin/bash

## Read from action | package from TCVS files and do the action to the package.
## Oh.. Yeah, that's "Triple Colon Separated Value"

cur_pid="$$"
config_scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
confs_dir="$config_scripts_dir/confs"

execute_action() {
	$action
}

parse_args() {
	case "${instruction[0]}" in
		ainst)
			action="apt-get install -y ${instruction[1]}"
			;;
		apurge)
			action="apt-get purge -y ${instruction[1]}"			
			;;
		dinst)
			deb_pkg="$(find . -name "*${instruction[1]}*" -exec echo {} \;)"
			action="dpkg -i $deb_pkg"
			;;
		dpurge)
			action="dpkg -P ${instruction[1]}"
			;;
		force)
			action="dpkg -P --force-depends ${instruction[1]}"
			;;
	esac
	execute_action
}

read_pkg_list() {
	for conf_line in $(cat "$pkg_list")
	do
		OIFS=$IFS
		IFS=":::"
		instruction=( ${conf_line[@]} )
		IFS=$OIFS
		parse_args
	done
}

iter_through_pkg_lists() {
	echo "iter_through_pkg_lists()"
	for pkg_list in $(find "$confs_dir" -name "*pkg-*.conf" -exec echo "{}" \;)
	do
		read_pkg_list
	done
	exit
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
