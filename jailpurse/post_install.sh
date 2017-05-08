#!/bin/bash





## Download and setup apparmor.
sudo apt-get install -y apparmor-utils
aa-status
PIDS=read

## Check world writable dirs for sticky bit.
## df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null

## Set sticky bit on world writable dirs.
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | chmod a+t

## Configure GPG keys
## apt-get update basically as long as we're using a debian base.

## Add aide.conf to crontab

## Set permissions on /boot/grub/grub.cfg to 400 => owner root:root
## Set a password for the bootloader
grub-mkpasswd-pbkdf2
## add this into grub.d/00_header
cat <<EOF
set superusers="<username>"
password_pbkdf2 <username> <encrypted-password> EOF
## Edit any GRUB config files here.
## Make sure GRUB does not contain any references to SELINUX or AppArmor.

## And then..
update-grub

## Set a password for root to prevent recovery mode reboot to a root prompt.
passwd root

## Check for unconfined daemons
ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'


