#!/bin/bash

## Setup image for editing.

echo "Extracting your configuration from the Jailpurse"

## Check to make sure we are in the chroot context.
if [ "$(ls -di / | grep -oP '^\d+')" -ne "2" ]; then

    echo "Establishing the Edit Context."
    ## Mount pseudo-filesystems
    if [ "$1" == 'enabled' ]; then
        mount --verbose -t proc none /proc/
        mount --verbose -t sysfs none /sys/
    fi

    ## Setup your environment
    cp /root/jailpurse/config-scripts/confs/bash-profile/.bash_aliases /root/ &&
    cp /root/jailpurse/config-scripts/confs/bash-profile/.bashrc /root/ &&
    cp /root/jailpurse/config-scripts/confs/bash-profile/.profile /root/ &&
    source /root/.profile

    echo "Image is ready to edit." 
else
    echo "You're not in chroot jail!!!"
    echo "You can't empty the Jailpurse here!!!"
    echo "Exiting.."
    exit 69;
fi
