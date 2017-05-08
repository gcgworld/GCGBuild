#!/bin/bash

## Check to make sure we are in the chroot context.
if [ "$(ls -di / | grep -oP '^\d+')" -ne "2" ]; then
    echo "Chrooted: Still In Edit-Mode..."
    echo "Proceeding with clean up..."
    apt-get clean
    rm -rf /root/jailpurse
    if [ "$1" == 'enabled' ]; then
        umount /proc/
        umount /sys/
    fi
    
    rm -rf /tmp/* 2>/dev/null && rm -rf /tmp/.* 2>/dev/null
    echo "Image clean: exiting Edit Context."
    exit
else
    echo "Not chrooted. exiting."
    exit 1;
fi

# intro_screen()
# show_help()
# setup_logging_framework()
# setup_logging_session()
# strip_trailing_dir_slash()
# confirm_cmd()
# set_version_string()
# increment_version()
# archive_last_version()
# select_new_base_image()
# check_for_dependencies()
# create_mount_dirs()
# mount_base_image()
# locate_image_squashfs()
# init_build_image()
# mount_fs()
# create_edit_fs()
# setup_guest_logging()
# setup_guest_networking()
# smuggle_in()
# enter_edit_image()
# start_gcg_lines()
# write_new_image_manifest()
# build_new_image_fs()
# generate_new_image_checksums()
# generate_new_iso()
# import_guest_logs()
# clean_up_guest_logs()
# clean_up_guest_apt()
# clean_up_guest_tmp()
# deactivate_guest()
# unmount_guest_fs()
# unmount_guest_base_image()
# clean_up_guest_files()
# write_to_usb()
# decision()
# load_edit_image()
# load_tools_into_image()
# edit_image()
# discard_changes()
# save_image()
# quit_gcgbuild()
# main()