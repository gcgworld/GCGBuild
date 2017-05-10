#!/bin/bash
intro_screen() {
    echo "$FUNCNAME"
cat << EOF
###############################################
## Gangster Computer God Linux Build System  ##
## AUTHOR: Gabriel Schroder                  ##
## All opinions represented here are my own  ##
## and not my employers. I don't have a job. ##
## Which is the only reason this now exists. ##
###############################################
EOF
}

show_help() {
    echo "$FUNCNAME"
    cat << EOF
    Usage: gcgbuild.sh [-options] [-b BASE_IMAGE]
    Options:
        -a, --activate-mount:
            Default: active="disabled"    

            Mount the /proc /sys and /dev
            pseudo-devices. To run the 
            OS, while you make changes.

            example: gcgbuild -a -n -b images/base/your_base.iso


        -A, --archive: "Project Name" "version number"
            ## Not yet implemented.
            Default: "project_name=this sessions project"
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
            
            Prevent the mounted system from 
            accessing your network from chroot
            jail.
            
            Example: gcgbuild -n
                     gcgbuild --no-networking


        -N, --no-jailpurse:
            Default: "jailpurse=enabled"

            Do not copy the jailpurse tool
            folder into the edit system.
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
                mkdir --verbose -p "$1"
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
                mkdir --verbose -p "$1"
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
                mkdir --verbose -p -v "$1"
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
                    # v_arg="$(echo "--verbose")"
                    
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



set_project_vars() {
    echo "$FUNCNAME"
    echo "Setting GCGBuild variables.."
    ## Static Program vars
    gcg_build_dir=$(dirname $(readlink -f $0))
    cmd_with_args=( $@ )
    session_start="$(date +%Y%m%d%H%M%S)"
    this_pid=$$
    log_funcs=$gcg_build_dir/logging
    intercom=$gcg_build_dir/intercom

    ## Mode: Build image from the current OS
    ## To be implemented when GCGLines is finished.
    # image_host=false 
    ## if true
    ## image_current_os > $gcg_build_dir/images/base/$project_name-$version.iso
    ## base_image=$gcg_build_dir/images/base/$project_name-$version.iso
    ## run normally from there! :D

    ## Default project name.
    if [ "$project_name" == "" ]; then
        project_name="GCGLinux"
    fi

    ## Default image to load.
    if [ "$base_image" == "" ]; then
        base_image=$gcg_build_dir/images/base/ubuntu-minimal.iso
        base_image_dir=$(echo dirname $(readlink -f $base_image))
        image_dir=$(echo dirname $base_image_dir)
    else
        base_image_dir=$(dirname $(readlink -f $base_image))
        image_dir=$(dirname $base_image_dir)
    fi

    ## Default custom image write dir
    if [ "$custom_image_dir" == "" ]; then
        custom_image_dir=$image_dir/custom/$project_name
    fi

    ## Default mount dirs.
    if [ "$root_mount_dir" == "" ]; then
        root_mount_dir="/mnt/$project_name"
        base_mount_dir="$root_mount_dir/base"
        base_fs_mount_dir="$root_mount_dir/fs"
        edit_fs_dir="$root_mount_dir/edit"
        build_image_dir="$root_mount_dir/build"
    else
        base_mount_dir="$root_mount_dir/base"
        base_fs_mount_dir="$root_mount_dir/fs"
        edit_fs_dir="$root_mount_dir/edit"
        build_image_dir="$root_mount_dir/build"
    fi

    ## Default Jailpurse vars
    if [ "$jailpurse" == "" ] || [ "$jailpurse" == "enabled" ]; then
        jailpurse="enabled"
        host_jailpurse=$gcg_build_dir/jailpurse
        edit_fs_jailpurse=$edit_fs_dir/root/jailpurse
    fi

    ## Logging vars
    if [ "$log_level" == "" ]; then
        log_level="none"
    fi

    ## Set default directory for logging
    if [ "$log_dir" == "" ]; then    
        project_log_dir="/var/log/gcg/$project_name"
        edit_fs_log_dir=$edit_fs_dir$project_log_dir
    else
        project_log_dir="/var/log/gcg/$project_name"
        edit_fs_log_dir=$edit_fs_dir$project_log_dir
    fi

    ## Should edit fs be activated with /proc /sys & /dev
    if [ "$active" == "" ] || [ "$active" == "disabled" ]; then 
        active="disabled"
        edit_fs_proc=""
        edit_fs_sys=""
        edit_fs_dev=""
    else
        edit_fs_proc=$edit_fs_dir/proc
        edit_fs_sys=$edit_fs_dir/sys
        edit_fs_dev=$edit_fs_dir/dev
    fi

    ## Should edit fs have network access?
    ## (requires edit fs be activated)
    ## This 

    if [ "$networking" == "" ]; then
        networking="disabled"
    fi

    ## Default verbosity
    if [ "$verbose" == "" ]; then
        verbose="info"
        v_phrase="1"
    fi

    ## Default installer edit to false.
    ## Create mount-point for it if true
    if [ "$edit_installer" == "" ]; then
        edit_installer="false"
    else
        if [ "$edit_installer" == "true" ]; then    
            edit_base_dir="$root_mount_dir/boot"
        fi
    fi

    ## Project specific vars
    version=( 0 0 1 )
    version_string="$(printf "%s.%s.%s" "${version[@]}")"

    ## Intercom
    host_intercom=$gcg_build_dir/intercom
    jailpurse_intercom=$host_jailpurse/intercom
    gcg_lines_intercom=$gcg_lines_dir/intercom

    ## Custom Image Title
    custom_image_name="$project_name-$version_string.iso"

    ## Write initial program vars to host_vars.init
    ( set -o posix ; set ) > $host_intercom/host_vars.init
}


## Utiliity functions
strip_trailing_dir_slash() {
    echo "$FUNCNAME"
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
    echo "$FUNCNAME"
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

check_for_dependencies() {
    echo "$FUNCNAME"
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


## Logging functions
create_log_dir() {
    echo "$FUNCNAME"
    if [ ! -d "/var/log/gcg" ]; then
        echo "First run with logging enabled.."
        echo "Setting up root GCG log directory.."
        mkdir --verbose -p /var/log/gcg
        echo "Finished setting up root GCG log directory.."
    else
        echo "Root GCG log directory exists.."
    fi
}

create_project_log_dir() {
    echo "$FUNCNAME"
    if [ ! -d "$project_log_dir" ]; then
        echo "$project_name is a new project.."
        echo "Setting up $project_name log directory.."
        mkdir --verbose -p $project_log_dir
        echo "Finished setting up $project_name log directory.."
    else
        echo "$project_name log directory exists.."
    fi
}

create_session_log_dirs() {
    echo "$FUNCNAME"
    echo "Setting up session log directories.."
    session_log_dir=$project_log_dir/$session_start
    mkdir --verbose -p $session_log_dir
    mkdir --verbose -p $session_log_dir/host
    mkdir --verbose -p $session_log_dir/host/events
    mkdir --verbose -p $session_log_dir/image/
    mkdir --verbose -p $session_log_dir/image/base/snapshot
    mkdir --verbose -p $session_log_dir/image/base_fs/snapshot
    mkdir --verbose -p $session_log_dir/image/edit_fs/snapshots
    mkdir --verbose -p $session_log_dir/image/edit_fs/commands
    mkdir --verbose -p $session_log_dir/image/edit_fs/events
    mkdir --verbose -p $session_log_dir/image/edit_fs/
    mkdir --verbose -p $session_log_dir/image/build
    echo "Finished setting up session log directories.."
}

setup_logging_session() {
    echo "$FUNCNAME"
    if [ "log_level" != "none" ]; then
        create_log_dir
        create_project_log_dir
        create_session_log_dirs
    fi
}

setup_edit_fs_logging() {
    if [ "$log_level" == "none" ]; then
        echo "Logging disabled: skipping config.."
    else
        echo "Setting up editable file system logging.."
        mkdir --verbose -p $edit_fs_log_dir/
        mkdir --verbose -p $edit_fs_log_dir/commands
        mkdir --verbose -p $edit_fs_log_dir/files
        mkdir --verbose -p $edit_fs_log_dir/events
        echo "Finish setting up editable file system logging.."
    fi
}

view_logs() {
    echo "I probably shoulda just done 'less /path/to/session/logs' huh?"
    echo "Yeah.. That's just not fancy enough..."
}


## Versioning functions
## Add archive_version() here.
set_version_string() {
    echo "$FUNCNAME"
    version_string=$(printf "%s.%s.%s" "${version[@]}")
}

increment_version() {
    echo "$FUNCNAME"
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


## Init base functions
create_base_mount_dir() {
    echo "$FUNCNAME"
    echo "Creating base mount directories.."
    mkdir --verbose -p $base_mount_dir
    echo "Finished creating base mount directories.."
}

create_edit_base_dir() {
    echo "$FUNCNAME"
    echo "Creating edit base directory.."
    mkdir --verbose -p $edit_base_dir
    echo "Finished creating edit base mount directory.."
}

create_base_fs_mount_dir() {
    echo "$FUNCNAME"
    echo "Creating base file system mount directory.."
    mkdir --verbose -p $base_fs_mount_dir
    echo "Finished creating base file system mount directory.."
}

create_edit_fs_dir() {
    echo "$FUNCNAME"
    echo "Creating edit file system directory.."
    mkdir --verbose -p $edit_fs_dir
    echo "Finished creating edit file system directory.."
}

create_build_image_dir() {
    echo "$FUNCNAME"
    echo "Creating build image directory.."
    mkdir --verbose -p $build_image_dir
    echo "Finished creating build image directory.."
}

create_mount_dirs() {
    echo "$FUNCNAME"
    echo "Creating mount directories.."
    create_base_mount_dir
    create_base_fs_mount_dir
    create_edit_fs_dir
    create_build_image_dir
    echo "Finished creating mount directories.."
}

mount_base_image() {
    echo "$FUNCNAME"
    echo "Mounting $base_image to $base_mount_dir.."
    if [ -d $base_mount_dir ]; then
        mount -o loop $base_image $base_mount_dir
    else
        create_base_mount_dir
        mount -o loop $base_image $base_mount_dir
    fi
    echo "Finished mounting $base_image at $base_mount_dir.."
}

locate_base_image_squashfs() {
    echo "$FUNCNAME"
    echo "Searching for squashfs file system.."
    cwd="$(pwd)"
    cd $base_mount_dir 
    image_fs=$(find -type f -exec file {} \; \
        | grep Squashfs \
        | grep -oP "^(\S)+" \
        | sed 's/://g' \
        | sed 's/^.//g')
    cd "$cwd"
    unset cwd
    echo "$image_fs"
    base_mount_fs=$base_mount_dir$image_fs
    echo "$base_mount_fs"
    echo "Found Squashfs File System: $base_mount_fs"
    sleep 5
}

mount_base_fs() {
    echo "$FUNCNAME"
    echo "Mounting file system.."
    if [ -d $base_fs_mount_dir ]; then
        mount --types squashfs --options loop $base_mount_fs $base_fs_mount_dir/
    else
        create_base_fs_mount_dir
        mount --types squashfs --options loop $base_mount_fs $base_fs_mount_dir/
    fi
    echo "Finished mounting file system.."
}

create_edit_fs() {
    ## TODO: Account for Fedora rootfs.img
    echo "$FUNCNAME"
    echo "Creating editable file system.."
    if [ -d $edit_fs_dir ]; then
        cp --verbose -a $base_fs_mount_dir/* $edit_fs_dir
    else
        create_edit_fs_dir
        cp --verbose -a $base_fs_mount_dir/* $edit_fs_dir
    fi
    echo "Editable file system ready.."
}

create_edit_base() {
    echo "$FUNCNAME"
    echo "Creating editable installer.."
    if [ -d $edit_base_dir ]; then
        cp --verbose -a $base_mount_dir/* $edit_base_dir
    else
        create_edit_base_dir
        cp --verbose -a $base_mount_dir/* $edit_base_dir
    fi
    echo "Finished creating editable installer.." ]
}

create_pre_build_image() {
    echo "$FUNCNAME";
    echo "Initializing build image.."
    if [ -d $build_image_dir ]; then
        rsync --verbose --archive --exclude=$image_fs $base_mount_dir/ $build_image_dir 
    else
        mkdir $build_image_dir
        rsync --verbose --archive --exclude=$image_fs $base_mount_dir/ $build_image_dir 
    fi
    echo "Finished initializing build image.."
}

setup_edit_fs_networking() {
    if [ "$networking" == "disabled" ]; then
        echo "Networking disabled: Skipping config.." 
    else    	
        echo "Establishing networking.."
        cp --verbose /etc/hosts $edit_fs_dir/etc
        echo "Edit file system networking enabled.."
    fi
}

stuff_jailpurse() {
    if [ "$jailpurse" == "disabled" ]; then
    	echo "jailpurse is disabled for this session."
        echo "external resources can still copied in manually."
    else
	    echo "Copying scripts to edit system.."
	    mkdir --verbose $edit_fs_jailpurse
	    cp --verbose -R $host_jailpurse/* $edit_fs_jailpurse/
	    echo "Finished copying scripts into edit system.."
	    echo "Running setup scripts in edit system.."
        chroot $edit_fs_dir bash -c "/root/jailpurse/gcg-edit-init.sh $active"
        echo "Edit file system setup is complete.."
    fi
}

enter_edit_fs() {
    echo "$FUNCNAME"
    echo "Entering image editing context.."
    echo "Hack like nobodies watching.."
    chroot $edit_fs_dir
    echo "You have exited the image editing context.."
}

enter_edit_base() {
    echo "$FUNCNAME"
    echo "Starting GCGLines.."
    ${path_to_gcglines} $(package_variables)
    echo "Re-entering GCGBuild.."
}

locate_image_manifest() {
    echo "$FUNCNAME"
    manifest_name="filesystem.manifest"
    ## Work in Arch next "pkglist.x86.txt", "pkglist.x86_64.txt"
    ## Not sure that Fedora has one.
    
    fs_manifest="$(find $base_mount_dir -name "$n" -exec echo {} \;)"
    fs_manifest_file="$(basename $fs_manifest)"
}

write_new_image_manifest() {
    echo "$FUNCNAME"
    ## Write new image manifest and write it to your change log.
    if [ "$fs_manifest_file" == "filesystem.manifest" ]; then
        echo "Creating package manifest for new image.."
        fs_manifest="$(find $build_image_dir -name "$fs_manifest_file" -exec echo {} \;)"
        chmod --verbose +w $fs_manifest
        chroot $edit_fs_dir dpkg-query -W --showformat='${Package} ${Version}\n' | tee $fs_manifest
        cp --verbose $fs_manifest $fs_manifest-$project_name
        echo "Finished package manifest for new image.."
    else
        echo "Not Debian/Ubuntu based distro"
    fi
}       

build_new_image_fs() {
    echo "$FUNCNAME"
    ## Build new filesystem from edited ...
    echo "Building new image file system.."
    mksquashfs $edit_fs_dir "$build_image_dir$image_fs" -no-recovery -noappend
    echo "New file system is built.."
}

generate_new_image_checksums() {
    echo "$FUNCNAME"
    ## Create list of new list checksums from file.manifest
    echo "Deleting old image checksum.."
    rm --verbose $build_image_dir/md5sum.txt
    echo "Finished deleting old image checksum.."
    cwd="$(pwd)"
    echo "Generating new image checksum.."
    cd --verbose $build_image_dir && find . -type f -print0 | xargs -0 md5sum | tee md5sum.txt && cd "$cwd"
    echo "Finished generating new image checksum.."
    unset cwd
    ## Change to a more secure hash once you have
    ## the locations it's checked in vmlinuz & initrd identified.
    # echo "Generating new image checksum.."
    # cd $build_image_dir && find . -type f -print0 | xargs -0 sha512sum | tee sha512sum.txt && cd -
    # echo "Finished generating new image checksum.."
}

generate_new_iso() {
    echo "$FUNCNAME"
    echo "Building $project_name-$version_string.iso .."
    genisoimage --verbose -r -V "$project_name-$version_string" -boot-info-table -b isolinux/isolinux.bin \
    -c isolinux/boot.cat -cache-inodes -l -no-emul-boot -boot-load-size 4 \
    -o /home/alberto/gcgbuild/images/custom/$project_name-$version_string.iso $build_image_dir
    echo "Finished building $project_name-$version_string.iso .."
}


## Edit fs write prep fucntions.
import_edit_fs_logs() {
    echo "$FUNCNAME"
	if [ "$log_level" == "none" ]; then
		echo "No session logs to clean.."
	else
		echo "Importing edit file system logs.."
		cp --verbose -R $edit_fs_dir/var/log/gcg/* /var/log/gcg/$project_name/$session_id/
		echo "Finished importing edit file system logs.."
    fi
}

clean_edit_fs_logs() {
    echo "$FUNCNAME"
	if [ "$log_level" == "none" ]; then
		echo "No session logs to clean.."
	else
		echo "Cleaning session logs on edit file system.."
		rm --verbose -rf $edit_fs_dir$host_log_dir
		echo "Finished cleaning session logs on edit file system.."
    fi
}

clean_edit_fs_apt() {	
    echo "$FUNCNAME"
    echo "Cleaning up apt.."
    chroot $edit_fs_dir bash -c "apt-get clean"
    echo "Finished cleaning apt.."
}

clean_edit_fs_tmp() {
    echo "$FUNCNAME"
    echo "Cleaning edit fs /tmp.."
    chroot $edit_fs_dir bash -c "rm -rf /tmp/* && rm -rf /tmp/.* 2>/dev/null"
    echo "Finished cleaning edit fs /tmp.."
}

deactivate_edit_fs() {
    echo "$FUNCNAME"
	if [ "$active" == "disabled" ]; then
		echo "Edit file system is not activated.."
	else
	    echo "Deactivating edit file system.."
	    umount --verbose $edit_fs_proc
	    umount --verbose $edit_fs_sys
        umount --verbose $edit_fs_dev
	    echo "Finished deactivating edit file system.."
    fi
}


## Session disassembly functions.
clean_edit_fs_all() {
    echo "$FUNCNAME"
    echo "Cleaning files in $edit_fs_dir.."
    rm --verbose -rf $edit_fs_dir/*
    echo "Finished cleaning files in $edit_fs_dir.."
}

delete_edit_fs() {
    echo "$FUNCNAME"
    echo "Deleting edit file system.."
    rm --verbose -rf $edit_fs_dir
    echo "Finished deleting edit file system.."
}

clean_build_image_all() {
    echo "$FUNCNAME"
    echo "Cleaning files build image.."
    rm --verbose -rf $build_image_dir/*
    echo "Finished cleaning files build image.."
}

delete_build_image() {
    echo "$FUNCNAME"
    echo "Deleting build image.."
    rm --verbose -rf $build_image_dir
    echo "Finished deleting build image.."
}

unmount_base_fs() {
    echo "$FUNCNAME"
	echo "Unmounting base file system.."
	umount --verbose $base_fs_mount_dir
	echo "Finished unmounting base file system file system.."
}

delete_base_fs() {
    echo "$FUNCNAME"
    echo "Deleting base file system.."
    rm --verbose -rf $base_fs_mount_dir
    echo "Finished deleting base file system.."
}

clean_edit_base_all() {
    echo "$FUNCNAME"
    echo "Deleting files in $edit_base_dir.."
    rm --verbose -rf $edit_base_dir/*
    echo "Finished deleting files in $edit_base_dir.."
}

delete_edit_base() {
    echo "$FUNCNAME"
    echo "Deleting edit base image.."
    rm --verbose -rf $edit_base_dir
    echo "Finished deleting edit base image.."
}

unmount_base_image() {
    echo "$FUNCNAME"
	echo "Unmounting edit base image.."
	umount --verbose $base_mount_dir
	echo "Finished unmounting edit base image.."
}

delete_base_image() {
    echo "$FUNCNAME"
    echo "Deleting base image.."
    rm --verbose -rf $base_mount_dir
    echo "Finished deleting base image.."
}

delete_project_mount() {
    echo "$FUNCNAME"
    echo "Deleting project root mount directory.."
    rm --verbose -rf $root_mount_dir
    echo "Finished deleting project root mount directory.."
}

write_to_usb() {
    echo "$FUNCNAME"
    echo "Select drive."
    echo "Format drive."
    echo "Wipe drive."
    echo "Zero, urandom, or Mersenne prime twister."
    echo "Create partitions. For OS, and for Storage."
    echo "Write the OS to the partition."
    echo "Create an encryption key for the storage."
}


archive_last_version() {
    echo "$FUNCNAME"
    echo "This function will archive the last version."
    echo "So that you can backtrack if you want/need to"
    echo "Fix something."
}

change_custom_image_to_base() {
    echo "$FUNCNAME"
    echo "Copying $custom_image_name to $base_image_dir.."
    cp --verbose -av images/custom/$custom_image_name images/base/
    echo "Finished copying $custom_image_name to $base_image_dir.."
    echo "Switching base image to $base_image_dir/$custom_image_name.."
    base_image=images/base/$custom_image_name
    base_image_dir=$(dirname $(readlink -f $base_image))
    image_dir=$(dirname $base_image_dir)
    echo "Base image is now $base_image_dir/$custom_image_name.."
    echo "Incrementing version .."
    # rm $custom_image_dir/$custom_image_name
    increment_version
    echo "Setting new custom image.."
    custom_image_name="$project_name-$version_string.iso"
    echo "Custom image is now $custom_image_name.."
}

select_different_project() {
    unset project_name
    unset base_image
    echo "Project Name: "; read project_name
    echo "Base Image: "; read base_image
}

view_manual() {
    man gcgbuild
    decision
}

decision() {
    echo "$FUNCNAME"
    echo "What's next?"
    echo "[0] Return to editing your image."
    echo "[1] Save your changes to your image to the ISO and keep working."
    echo "[2] Save your changes to your image to the ISO and work on another project."
    echo "[3] Save your changes to your image to the ISO and quit."
    echo "[4] Discard your changes and start over."
    echo "[5] Discard your changes and work on another project."
    echo "[6] Discard changes and quit."
    echo "[7] Customize the installer. (Requires GCGLines)"
    echo "[8] View the User manual."
    echo "[9] View the logs for this session."
    echo "[Q]uit"
    read choice

    case $choice in
    	0)
			enter_edit_fs
            decision
			;;
		1)
			clean_edit_fs
            save_custom_build
            clear_project_mount
            change_custom_image_to_base
	        init_session
	        enter_edit_context
	        ;;
	    2)
			clean_edit_fs
            save_custom_build
            clear_project_mount
            select_different_project
            init_session
            enter_edit_context
        	;;
        3)
			clean_edit_fs
            save_custom_build
            clear_project_mount
            quit_gcgbuild
			;;
		4)
			discard_changes
	        init_edit_context
	        enter_edit_context
			;;
		5)
	        clear_project_mount
            select_different_project
	        init_session
	        enter_edit_context
	        ;;
	    6)
			clear_project_mount
            quit_gcgbuild
	        ;;
		7)
			init_edit_base
            enter_edit_base
	        decision
	        ;;
        8)
            view_logs
            decision
            ;;
        9)
            view_manual
            decision
            ;;
        q|Q)
            quit_gcgbuild
            ;;
	esac
}

## "Super-Functions" for user flows.

## Session initiation functions.
init_base() {
    echo "$FUNCNAME"
    create_mount_dirs
    mount_base_image
}

init_base_fs() {
    echo "$FUNCNAME"
    locate_base_image_squashfs
    mount_base_fs
}

init_edit_context() {
    echo "$FUNCNAME"
    create_edit_fs
    setup_edit_fs_logging
    setup_edit_fs_networking
    stuff_jailpurse
}

init_build_image() {
    echo "$FUNCNAME"
    ## Add edit_base 
    ## this for GCGLines integration.
    create_pre_build_image
}

init_session() {
    init_base
    init_base_fs
    init_edit_context
}

enter_edit_context() {
    echo "$FUNCNAME"
    enter_edit_fs
    decision
}

## Session saving and writing functions.
save_custom_build() {
    echo "$FUNCNAME"
    init_build_image
    write_new_image_manifest
    build_new_image_fs
    generate_new_image_checksums
    generate_new_iso
}

## Session dismantling functions.
clean_edit_fs() {
    echo "$FUNCNAME"
    clean_edit_fs_apt
    clean_edit_fs_tmp
    import_edit_fs_logs
    clean_edit_fs_logs
    deactivate_edit_fs
}

clear_edit_fs() {
    echo "$FUNCNAME"
    deactivate_edit_fs
    delete_edit_fs
}

clear_build_image() {
    echo "$FUNCNAME"
    delete_build_image
}

clear_base_fs() {
    echo "$FUNCNAME"
    unmount_base_fs
    delete_base_fs
}

clear_base_image() {
    echo "$FUNCNAME"
    unmount_base_image
    delete_base_image
}

clear_project_mount() {
    echo "$FUNCNAME"
    clear_edit_fs
    clear_base_fs
    clear_base_image
    delete_project_mount
}

load_new_project() {
    echo "$FUNCNAME"
    set_project_vars
    select_new_base_image
}

discard_changes() {
    echo "$FUNCNAME"
    clear_edit_fs
    clear_build_image
}

quit_gcgbuild() {
    echo "$FUNCNAME"
    if [ -d $root_mount_dir ]; then
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
    fi
    echo "Exiting.."
    exit
}

main() {
    echo "$FUNCNAME"
    intro_screen
    set_project_vars
    init_session
    enter_edit_context
}

main