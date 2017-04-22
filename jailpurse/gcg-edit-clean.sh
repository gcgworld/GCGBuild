#!/bin/bash

## Check to make sure we are in the chroot context.
if [ "$(ls -di / | grep -oP '^\d+')" -ne "2" ]; then
    echo "Chrooted: Still In Edit-Mode..."
    echo "Proceeding with clean up..."
    apt-get clean
    rm -rf /tmp/* 2>/dev/null && rm -rf /tmp/.* 2>/dev/null
	rm -rf /root/jailpurse
    umount /proc/
    umount /sys/
    echo "Image clean: exiting Edit Context."
    exit
else
    echo "Not chrooted. exiting."
    exit 1;
fi
