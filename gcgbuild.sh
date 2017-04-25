#!/bin/bash

##############################################
## Gangster Computer God Linux Build System ##
##############################################

show_help() {
    cat << EOF
    Usage: gcgbuild.sh [-options] [-f BASE_IMAGE]
    Options:
        -h, --help: Show this message and exit.
        
        
        -l, --log-dir: "\e[4m/path/to/log/dir\e[0m"
            Default is "\e[4m/var/log/gcg\e[0m"
        
            Select directory for changelog.
            If directory does not exist, gcg will
            attempt to create it.
        
            example: gcgbuild -l /tmp/gcg/changelog
                     gcgbuild --log-dir ~/log/gcg

        
        -L, --log-level:
            Default: "\e[4mInfo\e0m"

            0 = None   "No logging."
            1 = Entry  "Log commands issued editing."
            2 = Info   "Log files added/deleted changed."
            3 = Debug  "Log everything we can think of."



        -m, --mount-point: "\e[4m/path/to/mnt/dir\e[0m"
            Default: "\e[4m/mnt\e0m"
            
            Choose base directory to mount the 
            base image, the filesystem, create
            the copy of the filesystem to edit,
            and the copy of the image we will 
            add our changes too, and build from.

            Example: gcgbuild -m /tmp/gcg
                     gcgbuild --mount-point /opt/mountpoint

        
        -n, --enable-networking:
            Default: "\e[4mnetwork-disabled\e0m"
            
            Allow the mounted file system to 
            access your network from chroot
            jail.
            
            Example: gcgbuild -n
                     gcgbuild --enable-networking


        -o, --output-target:
            Default: "\e[4m/gcgbuild/images/custom\e0m"

            Choose destination to write custom image
            after it has been built.

            Example: gcgbuild -o ~/OpSystems
                     gcgbuild --output-target /tmp/build/gcg


        -t, --title:
            Default: "\e[4m/gcgbuild/images/custom\e0m"

            Choose destination to write custom image
            after it has been built.

            Example: gcgbuild -t "GCGLinux"
                     gcgbuild --title "Eunice"


        -v, --verbose: 
            Default: "\e[4mInfo\e0m"

            0 = Event  "Only notify for user action."
            1 = Info   "Notify when each step finishes."
            2 = Debug  "Print every step to STDOUT."

}


gcg_build_dir=$(dirname $(readlink -f $0))
image_dir=$gcg_build_dir/images
base_image_dir=$image_dir/base
custom_image_dir=$image_dir/custom
root_mount_dir=/mnt
base_mount_dir=$root_mount_dir/base
base_image_fs=$base_mount_dir/casper/filesystem.squashfs
fs_mount_dir=$root_mount_dir/fs
edit_mount_dir=$root_mount_dir/edit
build_mount_dir=$root_mount_dir/build
host_jailpurse=$gcg_build_dir/jailpurse
guest_jailpurse=$edit_mount_dir/root/jailpurse
log_dir=/var/log/gcg
log_level="logging-none"
networking="network-disabled"
verbose="info"
project_name="GCGLinux"
version="0.0.1"
image_host=false  ## This is going to be the most challenging part.


while [ "$1" ]
do
    case $1 in
        -b|--base-image)
            shift
            if [ -f $1 && "$(file -b $1 | grep -oP '^\w+\s+\w+')" == "ISO 9660" ]; then
                base_image=$1
            else
                echo "Base image doesn't appear to be a bootable ISO."
                exit 1;
            fi
            ;;
        -h|--help)
            show_usage()
            exit
            ;;
        -i|--image-host)
            image_host=true
            ;;            
        -l|--log-dir)
            ## Set log directory
            shift
            if [ -d "$1" ]; then
                log_dir="$1"
            else
                mkdir -p "$1"
                if [ -d "$1" ]; then
                    log_dir="$1"
                else
                    echo "Could not make directory at $1"
                    exit 1;
                fi
            fi
            ;;
        -m|--mount-point)
            shift
            if [ -d "$1" ]; then
                root_mount_dir="$1"
            else
                mkdir -p "$1"
                if [ -d "$1" ]; then
                    root_mount_dir="$1"
                else
                    echo "Could not make directory at $1"
                    exit 1;
                fi
            fi
            ;;
        -n|--enable-networking)
            networking="network-enabled"
            ;;
        -t|--title)
            shift
            project_name="$1"
            ;;
        -v|--verbose)
            shift
            if [ "$1" -ge 0 -a $1 -le 2 ]; then
                if [ "$1" == "0" ]; then
                    verbose="event"
                fi
                if [ "$1" == "1" ]; then
                    verbose="info"
                fi
                if [ "$1" == "2" ]; then
                    verbose="debug"
                fi
            else
                echo "Verbosity argument was $1"
                echo "Must be an integer between 0-2"
                exit 1;
            fi
            ;;     
    esac
    shift
done
exit 0;


create_directories() {
    if [ "$verbose" == "event" ]; then
        mkdir -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating direcetory mount points.."
        mkdir -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
        echo "Mount points created.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Creating direcetory mount points.."
        mkdir --verbose -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
        echo "Mount points created.."
    fi
    exit
}

mount_base_image() {
    if [ "$verbose" == "event" ]; then
        mount -o loop $base_image $base_mount_dir
    fi
    if [ "$verbose" == "info" ]; then
        echo "Mounting base image to $base_mount_dir.."
        mount -o loop $base_image $base_mount_dir
        echo "Finished mounting base image at $base_mount_dir.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Mounting base image to $base_mount_dir.."
        mount --verbose -o loop $base_image $base_mount_dir
        echo "Finished mounting base image at $base_mount_dir.."
    fi
    exit
}

init_build_image() {
    if [ "$verbose" == "event" ]; then
        rsync --quiet --archive --exclude=/casper/filesystem.squashfs $base_mount_dir/ $build_mount_dir    
    fi
    if [ "$verbose" == "info" ]; then
        echo "Initializing build image..";
        rsync --archive --exclude=/casper/filesystem.squashfs $base_mount_dir/ $build_mount_dir
        echo "Finished initializing build image.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Initializing build image..";
        rsync --archive --verbose --exclude=/casper/filesystem.squashfs $base_mount_dir/ $build_mount_dir 
        echo "Finished initializing build image.."
    fi
    exit
}

mount_fs() {
    if [ "$verbose" == "event" ]; then
        mount --types squashfs --options loop $base_mount_dir/casper/filesystem.squashfs $fs_mount_dir/
    fi
    if [ "$verbose" == "info" ]; then
        echo "Mounting file system..";
        mount --types squashfs --options loop $base_mount_dir/casper/filesystem.squashfs $fs_mount_dir/
        echo "Finished mounting file system.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Mounting file system..";
        mount --types squashfs --options loop $base_mount_dir/casper/filesystem.squashfs $fs_mount_dir/
        echo "Finished mounting file system.."
    fi
    exit
}

create_edit_fs() {
    if [ "$verbose" == "event" ]; then
        cp -a $fs_mount_dir/* $edit_mount_dir
        mkdir $edit_mount_dir/root/jailpurse
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating editable file system..";
        cp -a $fs_mount_dir/* $edit_mount_dir
        mkdir $edit_mount_dir/root/jailpurse
        echo "Editable file system ready.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Creating editable file system..";
        cp --verbose -a $fs_mount_dir/* $edit_mount_dir
        mkdir --verbose $edit_mount_dir/root/jailpurse
        echo "Editable file system ready.."
    fi
    exit
}

mount_fs() {
    if [ "$verbose" == "event" ]; then
        cp -R $host_jailpurse/* $guest_jailpurse
    fi
    if [ "$verbose" == "info" ]; then
        echo "Copying scripts into guest system.."
        cp -R $host_jailpurse/* $guest_jailpurse
        echo "Finished copying scripts into guest system.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Copying scripts to guest system.."
        cp -R $host_jailpurse/* $guest_jailpurse
        echo "Finished copying scripts into guest system.."
    fi
    exit
}

networking() {
    if [ "$verbose" == "event" ]; then
        cp /etc/hosts $edit_mount_dir/etc
    fi
    if [ "$verbose" == "info" ]; then
        echo "Establishing networking.."
        cp /etc/hosts $edit_mount_dir/etc
        echo "Guest networking enabled.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Establishing networking.."
        cp --verbose /etc/hosts $edit_mount_dir/etc
        echo "Guest networking enabled.."
    fi
    exit
}

setup_guest_internals() {
    if [ "$verbose" == "event" ]; then
        chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
    fi
    if [ "$verbose" == "info" ]; then
        echo "Running setup scripts in guest system.."
        chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
        echo "Guest setup is complete.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Runinng setup scripts in guest system.."
        chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
        echo "Guest setup is complete.."
    fi
    echo "Everything is setup and ready to edit.."
    exit
}

edit_system() {
    echo "Entering guest context.."
    echo "Hack like nobodies watching.."
    chroot $edit_mount_dir
    echo "You have exited the guest.."
    exit
}

write_new_image_manifest() {
    if [ "$verbose" == "event" ]; then
        chmod +w $build_mount_dir/casper/filesystem.manifest
        chroot $edit_mount_dir dpkg-query -W --showformat='${Package} ${Version}\n' > $build_mount_dir/casper/filesystem.manifest
        cp $build_mount_dir/casper/filesystem.manifest $build_mount_dir/casper/filesystem.manifest-$project_name
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating package manifest for new image.."
        chmod +w $build_mount_dir/casper/filesystem.manifest
        chroot $edit_mount_dir dpkg-query -W --showformat='${Package} ${Version}\n' > $build_mount_dir/casper/filesystem.manifest
        cp $build_mount_dir/casper/filesystem.manifest $build_mount_dir/casper/filesystem.manifest-$project_name
        echo "Finished package manifest for new image.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Creating package manifest for new image.."
        chmod --verbose +w $build_mount_dir/casper/filesystem.manifest
        chroot $edit_mount_dir dpkg-query -W --showformat='${Package} ${Version}\n' | tee $build_mount_dir/casper/filesystem.manifest
        cp --verbose $build_mount_dir/casper/filesystem.manifest $build_mount_dir/casper/filesystem.manifest-$project_name
        echo "Finished package manifest for new image.."
    fi
    exit   
}

build_new_image_fs() {
    if [ "$verbose" == "event" ]; then
        mksquashfs $edit_mount_dir $build_mount_dir/casper/filesystem.squashfs
    fi
    if [ "$verbose" == "info" ]; then
        echo "Building new image file system.."
        mksquashfs $edit_mount_dir $build_mount_dir/casper/filesystem.squashfs
        echo "New file system is built.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Building new image file system.."
        mksquashfs --verbose $edit_mount_dir $build_mount_dir/casper/filesystem.squashfs
        echo "New file system is built.."
    fi
    exit
}

generate_new_image_checksums() {
    if [ "$verbose" == "event" ]; then
        rm $build_mount_dir/md5sum.txt
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum > sha256sum.txt
    fi
    if [ "$verbose" == "info" ]; then
        echo "Deleting old image checksum.."
        rm $build_mount_dir/md5sum.txt
        echo "Generating new image checksum.."
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum > sha256sum.txt
        echo "New file system checksums have been generated.."        
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Deleting old image checksum.."
        rm --verbose $build_mount_dir/md5sum.txt
        echo "Generating new image checksum.."
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum | tee sha256sum.txt
        echo "New file system checksums have been generated.."
    fi
    exit
}

generate_new_iso() {
    
    if [ "$verbose" == "event" ]; then
        genisofs -r -V "$NAME_OF_DISTRO$VERSION" -b isolinux/isolinux.bin -c isolinux/boot.cat \
        -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o $custom_image_dir .
    fi
    if [ "$verbose" == "info" ]; then
        echo "Building $project_name$version.iso.."
        genisofs -r -V "$project_name$version" -b isolinux/isolinux.bin -c isolinux/boot.cat \
        -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o $custom_image_dir .
        echo "Finished building $project_name$version.iso.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Building $project_name$version.iso.."
        genisofs -r -V "$project_name$version" -b isolinux/isolinux.bin -c isolinux/boot.cat \
        -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o $custom_image_dir .
        echo "Finished building $project_name$version.iso.."
    fi
    exit
}

clean_up() {
    if [ "$verbose" == "event" ]; then
        umount $fs_mount_dir
        umount $base_mount_dir
        rm -rf /mnt/*
    fi
    if [ "$verbose" == "info" ]; then
        echo "Cleaning up temporary files.."
        umount $fs_mount_dir
        umount $base_mount_dir
        rm -rf /mnt/*
        echo "Finished cleaning temporary files.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Cleaning up temporary files.."
        umount --verbose $fs_mount_dir
        umount --verbose $base_mount_dir
        rm -rfv /mnt/*
        echo "Finished cleaning temporary files.."
    fi
    exit
}

## Returning to the host system.

echo "How would you like to proceed?"
echo "[W]rite changes to image\n
[R]eturn to editing\n
[D]iscard changes and clean up\n
[N]othing, just exit."
echo "Select an option and press Enter: "
read NEXT_ACTION
