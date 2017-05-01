#!/bin/bash

intro_screen() {
    cat << EOF

##############################################
## Gangster Computer God Linux Build System ##
##                                          ##
##                                          ##
##                                          ##
##############################################

EOF
}


show_help() {
    cat << EOF
    Usage: gcgbuild.sh [-options] [-b BASE_IMAGE]
    Options:
        -b, --base-image: $(echo -e "\e[4m/path/to/base_image.iso\e[0m")

            Choose image to edit.

            example: gcgbuild -b images/base/ubuntu-desktop-14.04.05.iso


        -h, --help: Show this message and exit.
        
        
        -l, --log-dir: $(echo -e "\e[4m/path/to/log/dir\e[0m")
            Default: $(echo -e "\e[4m/var/log/gcg\e[0m")
        
            Select directory for changelog.
            If directory does not exist, gcg will
            attempt to create it.
        
            example: gcgbuild -l /tmp/gcg/changelog
                     gcgbuild --log-dir ~/log/gcg

        
        -L, --log-level: [0-3]
            Default: $(echo -e "\e[4mInfo\e[0m")

            0 = None   "No logging."
            1 = Entry  "Log commands issued editing."
            2 = Info   "Log files added/deleted changed."
            3 = Debug  "Log everything we can think of."


        -m, --mount-point: "\e[4m/path/to/mnt/dir\e[0m"
            Default: "\e[4m/mnt\e[0m"
            
            Choose base directory to mount the 
            base image, the filesystem, create
            the copy of the filesystem to edit,
            and the copy of the image we will 
            add our changes too, and build from.

            Example: gcgbuild -m /tmp/gcg
                     gcgbuild --mount-point /opt/mountpoint

        
        -n, --no-networking:
            Default: "\e[4mnetwork=enabled\e0m"
            
            Prevent the guest system from 
            accessing your network from chroot
            jail.
            
            Example: gcgbuild -n
                     gcgbuild --no-networking


        -N, --no-jailpurse:
            Default: jailpurse=enabled

            Do not copy the jailpurse tool
            folder into the guest system.
            Work with the raw image.

            Note: This inherently disables gcg
                  logging while editing the 
                  image.

            Example: gcgbuild -N
                     gcgbuild --no-jailpurse


        -o, --output-target:
            Default: "e[4m/gcgbuild/images/custom\e0m"

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


            #######################################
            #       Gangster Computer God™®       #
            # is a copyright of Gabriel Schroder. #
            #     All fucking rights reserved.    #
            # I am putting it on the internet,    #
            # and I mean, people use shit that    #
            # gets put on the internet.. duncare. #
            # But if you make money off it I get  #
            # 10%. Instagram donated 0 dollars to #
            # the Django Foundation... What else  #
            # is there to say about open source?  #
            #######################################

EOF
}

## Vars we want to initialize before we use user args
## to declare variables. Defaults.

## Default project name.
project_name="GCGLinux"

## Default image to load.
gcg_build_dir=$(dirname $(readlink -f $0))
image_dir=$gcg_build_dir/images
base_image_dir=$image_dir/base
base_image="/ubuntu-14.04.05-desktop-amd64.iso"
custom_image_dir=$image_dir/custom

## Default mount dir.
root_mount_dir="/mnt"

## Default Jailpurse vars
jailpurse="enabled"

## Logging vars
log_level="none"
host_log_dir=/var/log/gcg
guest_log_dir=/var/log/gcg

## Networking vars
networking="enabled"

## Default verbosity
verbose="info"

## Mode: Build image from the current OS
image_host=false  ## The how TBD

## Parse user arguments.
while [ "$1" ]
do
    case $1 in
        -b|--base-image)
            shift
            if [ -f $1 ] && [ "$(file -b $1 | grep -oP '^\w+\s+\w+')" == "ISO 9660" ]; then
                base_image=$1
            else
                if [ "$(isoinfo -d -i $1 | grep "is in ISO 9660")" != "" ]; then
                    base_image=$1
                else
                    echo "Base image doesn't appear to be a bootable ISO."
                    exit 1;
                fi
            fi
            ;;
        -h|--help)
            show_help
            exit 1;
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
        -L|--log-level)
            ## Set log level
            shift
            if [ $1 -ge 0 -a $1 -le 3 ]; then
                if [ "$1" == "0" ]; then
                    log_level="none"
                fi
                if [ "$1" == "1" ]; then
                    log_level="entry"
                fi
                if [ "$1" == "2" ]; then
                    log_level="info"
                fi
                if [ "$1" == "3" ]; then
                    log_level="debug"
                fi
            else
                echo "Log Level argument was $1"
                echo "Must be an integer between 0-3"
                exit 1;
            fi
            ;;
        -m|--mount-point)
            ## Set the base dir to mount the images
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
        -n|--no-networking)
            ## Disable networking for the guest image
            networking="disabled"
            ;;
        -N|--no-jailpurse)
            ## Disable jailpurse-tools import into the guest image
            jailpurse="disabled"
            ;;
        -o|--output-target)
            shift
            if [ -d "$1" ]; then
                custom_image_dir="$1"
                echo "$custom_image_dir"
                echo "custom_image_dir is $(pwd)"
            else
                echo "custom_image_dir is $1"
                mkdir -p -v "$1"
                echo "custom_image_dir is$(pwd)"
                if [ -d "$1" ]; then
                    custom_image_dir="$1"
                else
                    echo "Could not make directory at $1"
                    exit 1;
                fi
            fi
            ;;
        -t|--title)
            ## Set the title of the project
            shift
            project_name="$1"
            ;;
        -v|--verbose)
            ## Set the verbosity level
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
        -T|--TEST)
            ## Run with default config.
            while [ "$1" ]
            do
                shift
            done
            ;;
    esac
    shift
done

## Project custom vars

version=( 0 0 1 )
version_string="$(printf "%s.%s.%s" "${version[@]}")"

## Mount, Edit, and Build vars
root_mount_dir="$root_mount_dir/$project_name"
base_mount_dir="$root_mount_dir/base"
base_image_fs=""
fs_mount_dir="$root_mount_dir/fs"
edit_mount_dir="$root_mount_dir/edit"
build_mount_dir="$root_mount_dir/build"

host_jailpurse=$gcg_build_dir/jailpurse
guest_jailpurse=$edit_mount_dir/root/jailpurse

edit_mount_proc=$edit_mount_dir/proc
edit_mount_sys=$edit_mount_dir/sys

custom_image="$project_name-$version_string.iso"

# sessions=( if [ -d $host_log_dir/sessions ]; then read -r -a <<< "$(ls -l $host_log_dir/sessions/)" )
# edit_session_no=${#session[*]}
# edit_session_id="$(echo $host_log_dir/session/)"

setup_logging_framework() {
    if [ "$log_level" != "none" ]; then    
        if [ -d "/var/log/gcg" ]; then
            echo "Logging is implemented."
        else
            mkdir -p /var/log/gcg

            ## look for project name.
            ## increment session id.
            ## create new session folder.
            ## start running logging wrappers.
        fi
    fi
}

setup_logging_session() {
    echo "parse session_id /var/log/gcg/$profile/session_id"
    echo "increment session_id"
    echo "create /var/log/gcg/$profile/session_id"
    echo "create the subsidiary folders we decide on."

}

logging_wrapper_function() {
    # if verbose is off but log-level is high,
    # change the verbosity back to high
    # and run all functions in this wrapper
    # which will forward all stdout to /var/log/gcg/$profile/Session_id/init-log or whatever
    echo "We are going to use variables to pass parameters."
}

strip_trailing_dir_slash() {
    if [ -z $1 ]; then
        echo "No input.."
    else
        if [ "${$1:$((${#$1}-1))}" == "/" ] && [ "$1" != "/"]; then
            clean_path="${$1:0:$((${#$1}-1))}"
        fi
        return $clean_path
    fi
}

confirm_cmd() {
    if [ -z $1 ]; then
        echo "No command to check."
    else
        current_cmd="$(for arg in $@; do echo "$arg"; done)"
        loop_break=0
        while [ "$loop_break" != "1" ]
        do
            echo "$current_cmd"
            read run_that_shit
            case $run_that_shit in
                y|Y)
                    $current_cmd
                    loop_break="1"
                    ;;
                n|N)
                    echo "Declining to run: $current_cmd"
                    loop_break="1"
                    ;;
            esac
        done
    fi
}

set_version_string() {
    version_string=$(printf "%s.%s.%s" "${version[@]}")
}

increment_version() {
    if [ -z "$1" ] || [ "$1" == "minor" ]; then
        version[2]=$(( ${version[2]} + 1 ))
    fi
    if [ "$1" == "mid" ]; then
        version[1]=$(( ${version[1]} + 1 ))
    fi
    if [ "$1" == "major" ]; then
        version[0]=$(( ${version[0]} + 1 ))
    fi
    set_version_string
}

archive_last_version() {
    echo "This function will archive the last version."
    echo "So that you can backtrack if you want/need to"
    echo "Fix something."
}

select_new_base_image() {
    echo "This will be the pivot function to change the vars"
    echo "for when you want to switch to edit another image."
}



check_for_dependencies() {
    number_of_deps=$(wc -l dependencies.txt)
    for program_name in $(cat $gcg_build_dir/dependencies.txt)
    do
        OIFS=$IFS
        IFS=":"
        progpkg=( )
        for p in $program_name
        do
            progpkg[${#progpkg[*]}]="$p"  
        done
        IFS=$OIFS
        
        if [ "$(command -v ${progpkg[0]} >/dev/null 2>&1 || { echo "unavailable" >&2; })" == "unavailable" ]; then
            if [ "$(dpkg --search '${progpkg[0]}')" == "dpkg-query: no path found matching pattern *${progpkg[0]}*" ]; then
                echo "${progpkg[0]} is not available."
                echo ""
                echo "Would you like to install ${progpkg[1]} which contains ${progpkg[0]} right now?"
                echo "[y/n]"
                read install_missing_dep
                if [ "$install_missing_dep" == "y" ]; then
                    apt-get install -y "${progpkg[1]}"
                else
                    echo "Something may or may not work if you proceed."
                fi
            else
                echo "It appears that ${progpkg[0]} is installed."
                for l in $(dpkg --search ${progpkg[0]} | grep -oP "\/\S+")
                do
                    file $l | grep -P "^.*executable"
                done
                echo "Add this to the $PATH for the user running gcgbuild."
            fi               
        else
            echo "${progpkg[0]} is installed.."
        fi
    done
}

create_mount_directories() {
    if [ "$verbose" == "event" ]; then
        mkdir -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating directory mount points.."
        mkdir -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
        echo "Mount points created.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Creating direcetory mount points.."
        mkdir --verbose -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
        echo "Mount points created.."
    fi
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
}

locate_image_squashfs() {
    base_image_fs="$(find $base_mount_dir -name "*filesystem.squashfs" -exec echo "{}" \;)"
    base_mount_fs=${base_image_fs:$((${#base_mount_dir})):$((${#base_image_fs}))}
    echo "$base_mount_fs"
}

init_build_image() {
    if [ "$verbose" == "event" ]; then
        rsync --quiet --archive --exclude=$base_mount_fs $base_mount_dir/ $build_mount_dir    
    fi
    if [ "$verbose" == "info" ]; then
        echo "Initializing build image..";
        rsync --archive --exclude=$base_mount_fs $base_mount_dir/ $build_mount_dir
        echo "Finished initializing build image.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Initializing build image..";
        rsync --archive --verbose --exclude=$base_mount_fs $base_mount_dir/ $build_mount_dir 
        echo "Finished initializing build image.."
    fi
}

mount_fs() {
    squashfs_file_systems=$(find $base_mount_dir -name "*.squashfs")
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
}

create_edit_fs() {
    if [ "$verbose" == "event" ]; then
        cp -a $fs_mount_dir/* $edit_mount_dir
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating editable file system..";
        cp -a $fs_mount_dir/* $edit_mount_dir
        echo "Editable file system ready.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Creating editable file system..";
        cp --verbose -a $fs_mount_dir/* $edit_mount_dir
        echo "Editable file system ready.."
    fi
}

snapshot_edit_image() {
    if [ "$log_level" != "none" ]; then
        if [ -f /var/log/gcg/$project_name/$session_id/init-fs-snapshot.txt ]; then
            chroot $edit_mount_dir /bin/bash -c \
            "su - -c mkdir -p /var/log/gcg && \
            find . -type f -print0 | xargs -0 sha512sum > /var/log/gcg/end-fs-snapshot.txt && \
            find / >> /var/log/gcg/end-fs-tree.txt"
            cp $edit_mount_dir/var/log/gcg/end-fs-snapshot.txt /var/log/gcg/$project_name/$session_id/end-state/
            cp $edit_mount_dir/var/log/gcg/end-fs-tree.txt /var/log/gcg/$project_name/$session_id/end-state/
            sed -i '/\/var\/log\/gcg/d' /var/log/gcg/end-fs-snapshot.txt
            sed -i '/gcg/d' /var/log/gcg/end-fs-tree.txt
        else    
            chroot $edit_mount_dir /bin/bash -c \
            "su - -c mkdir -p /var/log/gcg && \
            find . -type f -print0 | xargs -0 sha512sum > /var/log/gcg/init-fs-snapshot.txt && \
            find / >> /var/log/gcg/init-fs-tree.txt"
            cp $edit_mount_dir/var/log/gcg/init-fs-snapshot.txt /var/log/gcg/$project_name/$session_id/init-state/
            cp $edit_mount_dir/var/log/gcg/fs-tree.txt /var/log/gcg/$project_name/$session_id/init-state/
            sed -i '/\/that\/test\/path/d' /var/log/gcg/init-fs-snapshot.txt
            sed -i '/gcg/d' /var/log/gcg/fs-tree.txt
        fi
    fi
}

smuggle_in() {
    if [ "$jailpurse" == "enabled" ]; then
        if [ "$verbose" == "event" ]; then
            mkdir $edit_mount_dir/root/jailpurse
            cp -R $host_jailpurse/* $guest_jailpurse
        fi
        if [ "$verbose" == "info" ]; then
            echo "Copying scripts into guest system.."
            mkdir $edit_mount_dir/root/jailpurse
            cp -R $host_jailpurse/* $guest_jailpurse
            echo "Finished copying scripts into guest system.."
        fi
        if [ "$verbose" == "debug" ]; then
            echo "Copying scripts to guest system.."
            mkdir --verbose $edit_mount_dir/root/jailpurse
            cp -R $host_jailpurse/* $guest_jailpurse/
            echo "Finished copying scripts into guest system.."
        fi
    else
        echo "jailpurse is disabled for this session."
        echo "external resources can still copied in manually."
    fi
}

setup_guest_networking() {
    if [ "$networking" == "enabled" ]; then
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
    else
        echo "Networking disabled: Skipping config.."
    fi
}

setup_guest_internals() {
    if [ "$jailpurse" == "enabled" ]; then
        if [ "$verbose" == "event" ]; then
            chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
        fi
        if [ "$verbose" == "info" ]; then
            echo "Running setup scripts in guest system.."
            chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
            echo "Guest setup is complete.."
        fi
        if [ "$verbose" == "debug" ]; then
            echo "Running setup scripts in guest system.."
            chroot $edit_mount_dir bash -c /root/jailpurse/gcg-edit-init.sh
            echo "Guest setup is complete.."
        fi
    fi
    echo "Everything is setup and ready to edit.."
}

setup_guest_logging() {
    if [ "$log_level" != "none" ]; then
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/commands
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/files
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/events
    else
        echo "Logging disabled: skipping config.."
    fi
}

enter_edit_image() {
    echo "Entering guest context.."
    echo "Hack like nobodies watching.."
    chroot $edit_mount_dir
    echo "You have exited the guest.."
}

package_variables() {
    # echo "Wrapping variable"
    _var_pass_wrapper=( )
    echo "${_var_pass_wrapper[@]}"
}

start_gcg_lines() {
    echo "Starting GCGLines.."
    ${path_to_gcglines} $(package_variables)
    echo "Re-entering GCGBuild.."
}

write_new_image_manifest() {
    ## Write new image manifest and write it to your change log.
    if [ "$verbose" == "event" ]; then
        chmod +w $build_mount_dir/casper/filesystem.manifest
        chroot $edit_mount_dir dpkg-query -W --showformat='${Package} ${Version}\n' > $build_mount_dir/casper/filesystem.manifest
        cp $build_mount_dir/casper/filesystem.manifest $build_mount_dir/casper/filesystem.manifest-$project_name
    fi
    if [ "$verbose" == "info" ]; then
        echo "Creating package manifest for new image.."
        chmod +w $build_mount_dir/casper/filesystem.manifest
        chroot dpkg-query -W --showformat='${Package} ${Version}\n' > $build_mount_dir/casper/filesystem.manifest
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
}

build_new_image_fs() {
    ## Build new filesystem from edited ...
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
}

generate_new_image_checksums() {
    ## Create list of new list checksums from file.manifest
    if [ "$verbose" == "event" ]; then
        rm $build_mount_dir/md5sum.txt
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum > sha256sum.txt && cd -
    fi
    if [ "$verbose" == "info" ]; then
        echo "Deleting old image checksum.."
        rm $build_mount_dir/md5sum.txt
        echo "Generating new image checksum.."
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum > sha256sum.txt && cd -
        echo "New file system checksums have been generated.."        
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Deleting old image checksum.."
        rm --verbose $build_mount_dir/md5sum.txt
        echo "Generating new image checksum.."
        cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum | tee sha256sum.txt && cd -
        echo "New file system checksums have been generated.."
    fi
}

generate_new_iso() {
    ## genisoimage options
    ## -r ~> sets more reasonable permissions than some other options.
    ## -V ~> sets VolumeID to be written to the master block. 32-char max.
    ## -boot-info-table ~> inserts a 56-byte boot information table into the 
    ## file specified following -b with an offset of 8 bytes. This is specific
    ## to the El-Torrito Boot Table.
    ## -c isolinux/boot.cat ~> specifies the path and filename of the boot catalog
    ## -cache-inodes ~> preserves hardlinks on the image when written to the new image.
    ##      can cause problems, on windows, -no-cache-inodes is safer use with cgywin.
    ## -J ~> generate Joliet directory records in addition to ISO9660 if you're loading on windows.
    ## -l ~> allow full 31-char filenames.
    ## -no-emul-boot ~> Specifies that the system should load this and exeute the image
    ##      without performing any disk emulation.
    ## -hard-disk-boot ~> specifies that the image is a hard disk, must begin with MBR
    ##      that contains a single partition. (For Running from USB)
    ## -boot-load-size ~> specifies the number of byte sectors [512 bytes] to load in
    ##      -no-emul-boot mode.
    ## -o /path/to/output_file.iso ~> output file destination. If none is specified goes
    ##      to stdout, can be written to a block device, and then mounted to test that
    ##      the image was compiled, written, and works correctly.
    ##          
    ## Features following prototype:
    ## 1) -hard-disk-boot or portable OS's.
    ## 2) Creating a block device and mounting to test the image.

    if [ "$verbose" == "event" ]; then
        genisoimage -r -V "$project_name" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o "$custom_image_dir/$project_name-$version_string.iso" 
    fi
    if  "$verbose" == "info" ]; then
        echo "Building $project_name-$version.iso.."
        genisoimage -r -V "$project_name$version_string" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o "$custom_image_dir/$project_name-$version_string.iso"
        echo "Finished building $project_name$version.iso.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Building $project_name-$version.iso.."
        genisoimage -r -V "$project_name$version_string" -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -o "$custom_image_dir/$project_name-$version_string.iso"
        echo "Finished building $project_name$version.iso"
    fi
}

clean_up_image() {
    ## if [ "$log_level" != "none" ]; then
    ##     cp -R $edit_mount_dir/var/log/gcg/session/* /var/log/gcg/session/image/
    ##     rm -rf $edit_mount_dir/var/log/gcg
    ## fi
    echo "Cleaning up image.."
    chroot $edit_mount_dir bash -c "/root/jailpurse/gcg-edit-clean.sh"
    echo "Finished cleaning image.."
}

clean_up_host() {
    if [ "$verbose" == "event" ]; then
        umount $fs_mount_dir
        umount $base_mount_dir
        rm -rf $root_mount_dir
    fi
    if [ "$verbose" == "info" ]; then
        echo "Cleaning up temporary files.."
        umount $fs_mount_dir
        umount $base_mount_dir
        rm -rf $root_mount_dir
        echo "Finished cleaning temporary files.."
    fi
    if [ "$verbose" == "debug" ]; then
        echo "Cleaning up temporary files.."
        umount --verbose $fs_mount_dir
        umount --verbose $base_mount_dir
        rm -rfv "$root_mount_dir"
        echo "Finished cleaning temporary files.."
    fi
}

write_to_usb() {
    echo "Select drive."
    echo "Format drive."
    echo "Wipe drive."
    echo "Zero or Mersenne prime twister."
    echo "Create partitions. For OS, and for Storage."
    echo "Write the OS to the partition."
    echo "Create an encryption key for the storage."
}

decision() {
    echo "What's next?"
    echo "[1] Save your changes to your .iso and keep working."
    echo "[2] Save your changes to your .iso and quit."
    echo "[3] View your logs."
    echo "[4] Discard your changes and start over."
    echo "[5] Discard your changes and work on another project."
    echo "[6] Discard changes and quit."
    echo "[7] View the User manual."
    echo "[8] Customize the installer. (Requires GCGLines)"
    echo "[Q]uit"
    read decision

    if [ "$decision" == "1" ]; then
        save_image
        base_image=$custom_image
        load_edit_image
        load_tools_into_image
        edit_image
    fi
    if [ "$decision" == "2" ]; then
        save_image
        exit
    fi
    if [ "$decision" == "3" ]; then
        view_logs
        decision
    fi
    if [ "$decision" == "4" ]; then
        discard_changes
        load_edit_image
        load_tools_into_image
        edit_image
    fi
    if [ "$decision" == "5" ]; then
        discard_changes
        select_new_base_image
        load_edit_image
        load_tools_into_image
        edit_image
    fi
    if [ "$decision" == "6" ]; then
        discard_changes
        echo "All Done!"
        exit 0;
    fi
    if [ "$decision" == "7" ]; then
        show_help
        decision
    fi
}

load_edit_image() {
    check_for_dependencies
    create_mount_directories
    mount_base_image
    init_build_image
    locate_image_squashfs
    mount_fs
    create_edit_fs
}

load_tools_into_image() {
    smuggle_in
    setup_guest_networking
    setup_guest_internals
    setup_guest_logging
}

edit_image() {
    enter_edit_image
    decision
}

discard_changes() {
    clean_up_image
    clean_up_host
}

save_image() {
    increment_version
    clean_up_image
    write_new_image_manifest
    build_new_image_fs
    generate_new_image_checksums
    generate_new_iso
}

quit_gcgbuild() {
    while true
    do
        echo "Would you like to clean out temp files from your workspace first? [y/n]"
        read clean_before_quit
        case $clean_before_quit in
            y|Y)
                discard_changes
                exit
                ;;
            n|N)
                exit
                ;;
        esac
    done       
    exit
}

main() {
    load_edit_image
    load_tools_into_image
    edit_image
}

main
