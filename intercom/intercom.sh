#!/bin/bash

## Intercom: A rudimentary named-pipe IPC system

## Parse the args to determine the pipes to create.
## args should be unexpanded arrays in the form:
## ( PID command permissions )
## permissions is an integer from 0-7 indicating
## whether a process can read/write/execute pipes
## If a process has execute permissions, it can
## destroy a pipe, create a new one, and adjust
## the perms for pipes of communicating processes. 

## We are also going to need a list of which procs
## should talk to and listen to which other procs.

processes=( )

while [ $1 ]
do
	processes[${#processes[*]}]=$1
	shift
done


