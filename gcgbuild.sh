#!/bin/bash
# intro_screen() {
#     cat << EOF
# ###############################################
# ## Gangster Computer God Linux Build System  ##
# ## AUTHOR: Gabriel Schroder                  ##
# ## All opinions represented here are my own  ##
# ## and not my employers. I don't have a job. ##
# ## Which is the only reason this now exists. ##
# ###############################################
# EOF
# }

show_help() {
    cat << EOF
    Usage: gcgbuild.sh [-options] [-b BASE_IMAGE]
    Options:
        -a, --activate-mount:
            Default: activated="disabled"    

            Mount the /proc and /sys
            pseudo-devices. To run the 
            OS, while you make changes.

            example: gcgbuild -a -n -b images/base/your_base.iso


        -A, --archive: "Project Name" "version number"
            ## Not yet implemented.
            Default: "project=this sessions project"
                     "version=current_version"

            Save an archive of your Project at
            a specific version.

            example: gcgbuild -A GCGLinux 0.1.1
                     gcgbuild --archive GCGLinux 0.1.1


        -b, --base-image: $(echo -e "\e[4m/path/to/base_image.iso\e[0m")

            Choose image to edit.

            example: gcgbuild -b images/base/ubuntu-desktop-14.04.05.iso


        -C, --clear-logs: "Project Name"
            ## Not yet implemented.
            Default: None. Must have argument.

            Deletes all logs in /var/log/gcg/<Project_Name>


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
            Default: "jailpurse=enabled"

            Do not copy the jailpurse tool
            folder into the guest system.
            Work with the raw image.

            Note: You can still copy
                  files into the system
                  manually.

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

## Parse user arguments.
while [ "$1" ]
do
    case $1 in
        -a|--activate-mount)
            active="enabled"
            ;;
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
        -I|--edit-installer)
            edit_installer=true
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
        -p|--project-name)
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
                    v_arg="--verbose "
                fi
                v_phrase="$1"
                    
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




# echo "[$session_start], [$cmd_with_args], $this_pid" >> "$gcg_build_dir/intercom/host_vars.init"
set_project_vars() {

    gcg_build_dir=$(dirname $(readlink -f $0))
    cmd_with_args=( $@ )
    session_start="$(date +%Y%m%d-%H%M%S)"
    this_pid=$$

    ## Mode: Build image from the current OS
    ## To be implemented when GCGLines is finished.
    # image_host=false 
    ## if true
    ## image_current_os > $gcg_build_dir/images/base/$project_name-$version.iso
    ## base_image=$gcg_build_dir/images/base/$project_name-$version.iso
    ## run normally from there! :D

    ## Default project name.
    [ "$project_name" == "" ] \
        && \
            project_name="GCGLinux" \
        || \
            true

    ## Default image to load.
    [ "$base_image" == "" ] \
        && \
            base_image=$gcg_build_dir/images/base/ubuntu-minimal.iso
            base_image_dir=$(echo dirname $(readlink -f $base_image))
            image_dir=$(echo dirname $base_image_dir)
        || \
            true

    ## Default custom image write dir
    [ "$custom_image_dir" == "" ] \
        && \
            custom_image_dir=$image_dir/custom
        || \
            true

    ## Default mount dir.
    [ "$root_mount_dir" == "" ] \
        && \
            root_mount_dir="/mnt"
        || \
            true

    ## Default Jailpurse vars
    [ "$jailpurse" == "" ] \
        && \
            jailpurse="enabled"
        || \
            true

    ## Logging vars
    [ "$log_level" == "" ] \
        && \
            log_level="none"
        || \
            true
    
    ## Set default directory for logging
    [ "$log_dir" == "" ] \
        && \
            host_log_dir="/var/log/gcg"
            edit_fs_log_dir="/var/log/gcg"
        || \
            true
    
    ## Should edit fs be activated with /proc /sys & /dev
    [ "$activated" == "" ] \
        && \
            activated="disabled"
        || \
            true

    ## Should edit fs have network access?
    ## (requires edit fs be activated)
    [ "$activated" == "enabled" ] \
        && \
        [ "$networking" == "" ] \
            && \
                networking="disabled"
            || \
                true
        || \
            true

    ## Default verbosity
    [ "$verbose" == "" ] \
        && \
            verbose="info"
            v_phrase="1"
            v_arg=""
        || \
            true

    ## Does the user want to edit the installer too?
    [ "$edit_installer" == "" ] \
        && \
            edit_installer="false"
            root_mount_dir="$(echo "$root_mount_dir/$project_name")"
            base_mount_dir="$root_mount_dir/base"
            base_image_fs=""
            fs_mount_dir="$root_mount_dir/fs"
            edit_mount_dir="$root_mount_dir/edit"
            build_mount_dir="$root_mount_dir/build"
        || \
            true    
    
    ## Static Program vars
    log_funcs=$gcg_build_dir/logging
    intercom=$gcg_build_dir/intercom

    ## Project custom vars
    version=( 0 0 1 )
    version_string="$(printf "%s.%s.%s" "${version[@]}")"

    ## Mount, Edit, and Build vars


    ## Jailpurse
    host_jailpurse=$gcg_build_dir/jailpurse
    guest_jailpurse=$edit_mount_dir/root/jailpurse

    ## Interhosts
    host_intercom=$gcg_build_dir/intercom
    jailpurse_intercom=$host_jailpurse/intercom

    ## Activated-guest FS's
    edit_mount_proc=$edit_mount_dir/proc
    edit_mount_sys=$edit_mount_dir/sys

    ## Custom Image Title
    custom_image="$project_name-$version_string.iso"

}

# sessions=( if [ -d $host_log_dir/sessions ]; then read -r -a <<< "$(ls -l $host_log_dir/sessions/)" )
# edit_session_no=${#session[*]}
# edit_session_id="$(echo $host_log_dir/session/)"

## Write initial program vars to host_vars.init
# ( set -o posix ; set ) >$gcg_build_dir/intercom/host_vars.init

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

setup_host_logging_session() {
    echo "parse session_id /var/log/gcg/$profile/session_id"
    echo "increment session_id"
    echo "create /var/log/gcg/$profile/session_id"
    echo "create the subsidiary folders we decide on."

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

create_mount_dirs() {
    (( "$v_phrase" < 1 )) || echo "Creating mount directories.."
    mkdir "$v_arg" -p $base_mount_dir $fs_mount_dir $edit_mount_dir $build_mount_dir
    (( "$v_phrase" < 1 )) || echo "Finished creating mount directories.."
}

mount_base_image() {
    (( "$v_phrase" < 1 )) || echo "Mounting $base_image to $base_mount_dir.."
    mount -o loop $base_image $base_mount_dir
    (( "$v_phrase" < 1 )) || echo "Finished mounting $base_image at $base_mount_dir.."
}

locate_image_squashfs() {
    (( "$v_phrase" < 1 )) || echo "Searching for filesystem.squashfs"
    base_image_fs="$(find $base_mount_dir -name "*filesystem.squashfs" -exec echo "{}" \;)"
    base_mount_fs=${base_image_fs:$((${#base_mount_dir})):$((${#base_image_fs}))}
    (( "$v_phrase" < 1 )) || echo "Found filesystem.squashfs: $base_mount_fs"
}

init_build_image() {
    (( "$v_phrase" < 1 )) || echo "Initializing build image.."
    rsync --archive "$v_arg" --exclude=$base_mount_fs $base_mount_dir/ $build_mount_dir 
    (( "$v_phrase" < 1 )) || echo "Finished initializing build image.."
}

mount_fs() {
    squashfs_file_systems=$(find $base_mount_dir -name "*.squashfs")
    (( "$v_phrase" < 1 )) || echo "Mounting file system..";
    mount --types squashfs --options loop $base_mount_dir/casper/filesystem.squashfs $fs_mount_dir/
    (( "$v_phrase" < 1 )) || echo "Finished mounting file system.."
}

create_edit_fs() {
    (( "$v_phrase" < 1 )) || echo "Creating editable file system..";
    cp "$v_arg" -a $fs_mount_dir/* $edit_mount_dir
    (( "$v_phrase" < 1 )) || echo "Editable file system ready.."
}

setup_guest_logging() {
    [ [ "$log_level" == "none" ] \
    && \
    	echo "Logging disabled: skipping config.." ] \
    || \
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/commands
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/files
        mkdir -p $edit_mount_dir/var/log/gcg/$session_id/events
}

setup_guest_networking() {
    [ [ "$networking" == "disabled" ] \
    && \
		(( "$v_phrase" < 1 )) || echo "Networking disabled: Skipping config.." ] \
	|| \
        (( "$v_phrase" < 1 )) || echo "Establishing networking.."
        cp "$v_args" /etc/hosts $edit_mount_dir/etc
        (( "$v_phrase" < 1 )) || echo "Guest networking enabled.."
}

smuggle_in() {
	## Signature Fancy Bash Ternary if statement replacement.
    [ [ "$jailpurse" == "disabled" ] \
    && \
    	(( "$v_phrase" < 1 )) || echo "jailpurse is disabled for this session." ]
        (( "$v_phrase" < 1 )) || echo "external resources can still copied in manually." ] \
    || \
	    (( "$v_phrase" < 1 )) || echo "Copying scripts to guest system.."
	    mkdir "$v_arg" $edit_mount_dir/root/jailpurse && \
	    cp "$v_arg" -R $host_jailpurse/* $guest_jailpurse/ && \
	    (( "$v_phrase" < 1 )) || echo "Finished copying scripts into guest system.."

	    (( "$v_phrase" < 1 )) || echo "Running setup scripts in guest system.."
        chroot $edit_mount_dir bash -c "/root/jailpurse/gcg-edit-init.sh $activated"
        (( "$v_phrase" < 1 )) || echo "Guest setup is complete.."
}

enter_edit_fs() {
    (( "$v_phrase" < 1 )) || echo "Entering image editing context.."
    echo "Hack like nobodies watching.."
    chroot $edit_mount_dir
    echo "You have exited the image editing context.."
}

start_gcg_lines() {
    echo "Starting GCGLines.."
    ${path_to_gcglines} $(package_variables)
    echo "Re-entering GCGBuild.."
}

write_new_image_manifest() {
    ## Write new image manifest and write it to your change log.
    (( "$v_phrase" < 1 )) || echo "Creating package manifest for new image.."
    chmod "$v_arg" +w $build_mount_dir/casper/filesystem.manifest
    chroot $edit_mount_dir dpkg-query -W --showformat='${Package} ${Version}\n' | tee $build_mount_dir/casper/filesystem.manifest
    cp "$v_arg" $build_mount_dir/casper/filesystem.manifest $build_mount_dir/casper/filesystem.manifest-$project_name
    (( "$v_phrase" < 1 )) || echo "Finished package manifest for new image.."
}

build_new_image_fs() {
    ## Build new filesystem from edited ...
    (( "$v_phrase" < 1 )) || echo "Building new image file system.."
    mksquashfs $v_arg $edit_mount_dir $build_mount_dir/casper/filesystem.squashfs
    (( "$v_phrase" < 1 )) || echo "New file system is built.."
}

generate_new_image_checksums() {
    ## Create list of new list checksums from file.manifest
    (( "$v_phrase" < 1 )) || echo "Deleting old image checksum.."
    rm $v_arg $build_mount_dir/md5sum.txt
    (( "$v_phrase" < 1 )) || echo "Finished deleting old image checksum.."
    (( "$v_phrase" < 1 )) || echo "Generating new image checksum.."
    cd $build_mount_dir && find . -type f -print0 | xargs -0 sha256sum | tee sha256sum.txt && cd -
    (( "$v_phrase" < 1 )) || echo "Finished generating new image checksum.."
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
    (( "$v_phrase" < 1 )) || echo "Building $project_name-$version.iso .."
    genisoimage -r -V "$project_name$version_string" -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -o "$custom_image_dir/$project_name-$version_string.iso"
    (( "$v_phrase" < 1 )) || echo "Finished building $project_name$version.iso .."
}

import_edit_fs_logs() {
	[ [ "$log_level" == "none"] \
	&& \
		(( "$v_phrase" < 1 )) || echo "No session logs to clean.." ] \
	|| \
		(( "$v_phrase" < 1 )) || echo "Importing guest logs.."
		cp "$v_arg" -R $edit_mount_dir/var/log/gcg/* /var/log/gcg/$project_name/$session_id/
		(( "$v_phrase" < 1 )) || echo "Finished importing guest logs.."
}

clean_edit_fs_logs() {
	[ [ "$log_level" == "none"] \
	&& \
		(( "$v_phrase" < 1 )) || echo "No session logs to clean.." ] \
	|| \
		(( "$v_phrase" < 1 )) || echo "Cleaning up session logs on guest.."
		rm "$v_arg" -rf $edit_mount_dir$host_log_dir
		(( "$v_phrase" < 1 )) || echo "Finished cleaning session logs on guest.."
}

clean_edit_fs_apt() {	
    (( "$v_phrase" < 1 )) || echo "Cleaning up apt.."
    chroot $edit_mount_dir bash -c "apt-get clean"
    (( "$v_phrase" < 1 )) || echo "Finished cleaning apt.."
}

clean_edit_fs_tmp() {	
    (( "$v_phrase" < 1 )) || echo "Cleaning up guest /tmp.."
    chroot $edit_mount_dir bash -c \
    	'rm $v_arg -rf /tmp/* && \
    	rm -$v_arg -rf /tmp/.* 2>/dev/null'
    (( "$v_phrase" < 1 )) || echo "Finished cleaning guest /tmp.."
}

deactivate_edit_fs() {  
	[ [ "$activated" == "disabled" ] ] \
	&& \
		(( "$v_phrase" < 1 )) || echo "Guest is not activated.." ] \
	|| \
	    (( "$v_phrase" < 1 )) || echo "Deactivating guest.."
	    umount "$v_arg" $edit_mount_proc
	    umount "$v_arg" $edit_mount_sys
	    (( "$v_phrase" < 1 )) || echo "Finished deactivating guest.."
}

unmount_base_fs() {
	(( "$v_phrase" < 1 )) || echo "Unmounting guest file system.."
	umount "$v_arg" $fs_mount_dir
	(( "$v_phrase" < 1 )) || echo "Finished unmounting guest file system.."
}

unmount_guest_base_image() {
	(( "$v_phrase" < 1 )) || echo "Unmounting guest base image.."
	umount "$v_arg" $base_mount_dir
	(( "$v_phrase" < 1 )) || echo "Finished unmounting guest base image.."
}

clean_up_guest_files() {
    (( "$v_phrase" < 1 )) || echo "Deactivating guest.."
    rm "$v_arg" -rf $root_mount_dir
    (( "$v_phrase" < 1 )) || echo "Finished deactivating guest.."
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
    echo "[0] Return to edit mode."
    echo "[1] Save your changes to your .iso and keep working."
    echo "[2] Save your changes to your .iso and work on another project."
    echo "[3] Save your changes to your .iso and quit."
    echo "[4] Discard your changes and start over."
    echo "[5] Discard your changes and work on another project."
    echo "[6] Discard changes and quit."
    echo "[7] View the User manual."
    echo "[8] Customize the installer. (Requires GCGLines)"
    echo "[9] View your logs."
    echo "[Q]uit"
    read choice

    case $choice in
    	0)
			edit_image
			;;
		1)
			save_image
	        base_image=$custom_image
	        load_edit_image
	        load_tools_into_image
	        edit_image
	        ;;
	    2)
			save_image
        	exit
        	;;
        3)
			view_logs
	        decision
			;;
		4)
			discard_changes
	        load_edit_image
	        load_tools_into_image
	        edit_image	
			;;
		5)
			discard_changes
	        select_new_base_image
	        load_edit_image
	        load_tools_into_image
	        edit_image
	        ;;
	    6)
			discard_changes
	        echo "All Done!"
	        exit 0
	        ;;
		7)
			show_help
	        decision
	        ;;
	esac
}

clean_edit_fs() {
    clean_edit_fs_apt
    import_edit_fs_logs
    clean_edit_fs_logs
    clean_edit_fs_tmp
}

save_edit_fs() {
    deactivate_edit_fs
    write_new_image_manifest
    build_new_image_fs
    generate_new_image_checksums
    generate_new_iso
}

clear_edit_mount() {
    deactivate_edit_fs
    unmount_edit_fs
    clear_edit_fs
    clear_build_image
}

clear_project_mount() {
    clear_edit_mount
    unmount_base_fs
    unmount_base
    clear_base_fs
    clear_base_image
}

load_new_project() {

}

load_edit_image() {
    # check_for_dependencies
    create_mount_dirs
    mount_base_image
    init_build_image
    locate_image_squashfs
    mount_fs
    create_edit_fs
}

load_tools_into_image() {
    smuggle_in
    setup_guest_internals
    setup_guest_networking
    setup_guest_logging
}

edit_image() {
    enter_edit_fs
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