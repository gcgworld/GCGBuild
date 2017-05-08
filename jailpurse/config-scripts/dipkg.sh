#!/bin/bash

## DIPkg (Delivery Intercept Package)

if [ -z $1 ]; then
	echo "Usage: dipkg <Package Name>" && exit
else
	package_name=$1
	if [ "$(apt-cache show $1 | grep "^\w")" == "N" ]; then
		echo "Wrong package name..." && exit
	fi
fi

get_pkg_dependencies() {
	pkg_dep_list=( $(apt-cache show $package_name | grep -P "^Depends.*$" | grep -oP " (\w+|\d+|\.|\+|\-)+ " ) )
	total_dep_list=( )
	while [ "${pkg_dep_list[@]}" != ""  ]
	do
		for i in $(seq 0 ${#pkg_dep_list[*]})
		do
			total_dep_list[${#total_dep_list[*]}]="${pkg_dep_list[$i]}"
			if [ "$(apt-cache show $dep | \
				grep -P "^Depends.*$" | \
				grep -oP " (\w+|\d+|\.|\+|\-)+ " )" == "" ]; then
				pkg_dep_list=( ${pkg_dep_list[@]:1:${#pkg_dep_list[*]}} )
				



}
