#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Based 100%, with deep gratitude, on EduGR's Answer from Unix StackExchange                  #
# https://unix.stackexchange.com/questions/260796/how-to-make-an-iso-of-my-installed-system   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

GCG_BUILD_DIR=$(dirname $0) 
PATH_TO_BASE_ISO=$1
PATH_TO_BUILD_ISO=$GCG_BUILD_DIR/images/custom
NAME_OF_DISTRO="GCGLinux"
VERSION="0.0.1"
INITIAL_MOUNT=/mnt/initial-image
FS_MOUNT=/mnt/image/squashfs
EDIT_MOUNT=/mnt/image/edit
BUILD_MOUNT=/mnt/image/build
HOST_SCRIPT_FOLDER=$GCG_BUILD_DIR/jailpurse
EDIT_SYSTEM_SCRIPT_FOLDER=$EDIT_MOUNT/root/jailpurse
HOST_ETC_FOLDER=$HOST_SCRIPT_FOLDER/etc
EDIT_SYSTEM_ETC_FOLDER=$EDIT_MOUNT/etc
HOST_BUILD_CONFIG=$GCG_BUILD_DIR/build-config

## Parse Options

if [ $# -eq 0 ] || [ -z $1 ]; then
    echo "Usage: editdist /path/to/YourDistro.iso";
    exit 1;
fi

mkdir --verbose -p $INITIAL_MOUNT $FS_MOUNT $EDIT_MOUNT $BUILD_MOUNT &&
mount --verbose -o loop $PATH_TO_BASE_ISO $INITIAL_MOUNT &&
rsync --verbose --exclude=/casper/filesystem.squashfs -a $INITIAL_MOUNT/ $BUILD_MOUNT &&
modprobe --verbose squashfs &&
mount --verbose -t squashfs -o loop $INITIAL_MOUNT/casper/filesystem.squashfs $FS_MOUNT/ &&
cp --verbose -a $FS_MOUNT/* $EDIT_MOUNT &&
mkdir --verbose -p $EDIT_SYSTEM_SCRIPT_FOLDER &&
cp -R --verbose $HOST_SCRIPT_FOLDER/* $EDIT_SYSTEM_SCRIPT_FOLDER/ &&
cp /etc/resolv.conf /etc/hosts $EDIT_SYSTEM_ETC_FOLDER &&
cp /etc/apt/sources.list $EDIT_SYSTEM_ETC_FOLDER/apt/ &&
chroot $EDIT_MOUNT bash -c /root/jailpurse/gcg-edit-init.sh && \
echo "Image is loaded and ready to enter..."
echo "Entering Edit Context."

chroot $EDIT_MOUNT

## Returning to the host system.
echo "Exited Edit Context..."
echo "How would you like to proceed?"
echo "[W]rite changes to image\n
[R]eturn to editing\n
[D]iscard changes and clean up\n
[N]othing, just exit."
echo "Select an option and press Enter: "
read NEXT_ACTION
## Lack of elif in bash without nested if. Case statement will be cleaner.
if [ $NEXT_ACTION == 'w' ] || [ $NEXT_ACTION == 'W' ]; then
    chmod +w $BUILD_MOUNT/casper/filesystem.manifest
    chroot $EDIT_MOUNT dpkg-query -W --showformat='${Package} ${Version}\n' > $BUILD_MOUNT/casper/filesystem.manifest
    cp $BUILD_MOUNT/casper/filesystem.manifest $BUILD_MOUNT/casper/filesystem.manifest-desktop
    mksquashfs $EDIT_MOUNT $BUILD_MOUNT/casper/filesystem.squashfs
    rm $BUILD_MOUNT/md5sum.txt
    sudo -s
    (cd $BUILD_MOUNT && find . -type f -print0 | xargs -0 md5sum > md5sum.txt && find . -type f -print0 | xargs -0 sha256sum > sha256sum.txt)
    cd $BUILD_MOUNT
    genisofs -r -V "$NAME_OF_DISTRO$VERSION" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o $PATH_TO_ISO .
	echo "Cleaning up temporary files..."
	umount --verbose $FS_MOUNT
	umount --verbose $INITIAL_MOUNT
	rm -rf /mnt/*
	echo "All Done!"
	exit 0
    # isohybrid $PATH_TO_ISO
fi

echo "Cleaning up temporary files..."
umount --verbose $FS_MOUNT
umount --verbose $INITIAL_MOUNT
rm -rf /mnt/*
echo "All Done!"
exit 0
