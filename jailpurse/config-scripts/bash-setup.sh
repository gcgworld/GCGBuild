#!/bin/bash

## Change some defaults in /etc/login.defs
## We're deleting the games folder anyways..
sed -i 's/ENV_PATH\tPATH=\/usr\/local\/bin:\/usr\/bin:\/bin:\/usr\/local\/games:\/usr\/games/ENV_PATH\tPATH=\/usr\/local\/bin:\/usr\/bin:\/bin/g' /etc/login.defs
## Up the umask to 027 
sed -i 's/UMASK\t\t022/UMASK\t\t027/g' /etc/login.defs

## Copy in and source our bash settings
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp $cur_dir/config-files/bash-profile/* ~/
source ~/.profile





