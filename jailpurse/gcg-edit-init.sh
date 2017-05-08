#!/bin/bash

## Setup image for editing.

## Check to make sure we are in the chroot context.
if [ "$(ls -di / | grep -oP '^\d+')" -ne "2" ]; then
    
    
    echo "Finishing establishing the Edit Context."
    ## Mount pseudo-filesystems
    if [ "$1" == 'enabled' ]; then
        mount --verbose -t proc none /proc/
        mount --verbose -t sysfs none /sys/
    fi

    ## Setup Your Environment
    cp /root/jailpurse/config-scripts/confs/bash-profile/.* /root/ &&
    source /root/.profile
    
    ## Setup Logs
        ## List of commands issued.
    mkdir -p /var/log/gcg/commands
        ## Initial and final with sha256sum and sha512sum
    mkdir -p /var/log/gcg/files
        ## Initial and final packages.
    
        ## Time started, finished.
    mkdir -p /var/log/gcg/session-info
        ## 

    echo "Image is ready to edit." 
else
    echo "Actually not chrooted! Exiting."
    exit 1;
fi
