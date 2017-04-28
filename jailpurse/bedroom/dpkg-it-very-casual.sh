#!/bin/bash

## Sometimes you may want to cheat on your package
## management system. He/She doesn't necessarily
## need to know everything about every program you
## use. We will be working on a shadow file system
## next, kind of like your own hourly-rate motel.

## Copy a dpkg package with the files it requires.
## I may take the time to work with checking and
## gathering dependencies in you know... in case
## she has some fun friends.

fuck_palace="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/the_bedroom"
mkdir -p $fuck_palace

try_to_get_them_pregnant() {
	if [ "$one_of_theyre_kinks" != "" ]; then
		cp --parents $the_thing_theyre_into $fuck_palace/$cute_lil_thang
	else
		cp --parents $the_thing_theyre_into $fuck_palace/$cute_lil_thang
		ln -s $fuck_palace/cute_lil_thang$the_thing_theyre_into fuck_palace/$one_of_theyre_kinks
	fi
}


discover_what_turns_them_on() {
	what_theyre_into_sexually=$(dpkg --listfiles ${cute_lil_thangs[$cute_lil_thang]})
	for the_thing_theyre_into in $what_theyre_into_sexually
	do
		if [ -f $the_thing_theyre_into ]; then
			try_to_get_them_pregnant	
		fi
		if [ -L $the_thing_theyre_into ]; then
			one_of_theyre_kinks="$the_thing_theyre_into"
			the_thing_theyre_into=readlink -f $the_things_theyre_into
			try_to_get_them_pregnant
			one_of_theyre_kinks=""
		fi
	done
}


get_them_back_to_your_place() {
	for ((cute_lil_thang=0 ; cute_lil_thang < ${#cute_lil_thangs[*]} ; cute_lil_thang++))
	do
		mkdir -p "$fuck_palace/${cute_lil_thangs[$cute_lil_thang]}"
		discover_what_turns_them_on
	done
}


make_the_booty_calls() {
	cute_lil_thangs=( )
	for ((name_and_nmbr=0 ; name_and_nmbr < ${#lil_black_book[*]} ; name_and_nmbr++))
	do
		cute_lil_thangs[${#cute_lil_thangs[*]}]="${lil_black_book[$name_and_nmbr]}"
	done
	get_them_back_to_your_place
}


have_game() {
	lil_black_book=( )
	for cutie_you_meet in $(dpkg --list | grep -oP 'ii\s+(\w+|\-|\:|\d+|\.)+' | grep -oP '\S+$')
	do
		lil_black_book[${#lil_black_book[*]}]="$cutie_you_meet"
	done
	make_the_booty_calls
}


swoop_all_the_ladies_town() {
	have_game
}


swoop_all_the_ladies_in_town
exit
