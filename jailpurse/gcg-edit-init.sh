#!/bin/bash

## Setup image for editing.



## Check to make sure we are in the chroot context.
if [ "$(ls -di / | grep -oP '^\d+')" -ne "2" ]; then
    echo "Finishing establishing the Edit Context."

    ## Mount pseudo-filesystems
    mount --verbose -t proc none /proc/
    mount --verbose -t sysfs none /sys/

    
    ## Set Environment Variables for scripts
    export HOME=/root
    export PATH=$PATH:/root/jailpurse

    
    echo "Image is ready to edit." 
else
    echo "Actually not chrooted! Exiting."
    exit 1;
fi
