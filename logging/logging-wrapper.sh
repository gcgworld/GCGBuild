#!/bin/bash

## Crude logging framework. I'm very sure, oh so very sure that there's
## a better solution. But I never built one. Don't want any dependencies
## beyond stock Bash on a modern linux distro.

## If you want something unfortunately obsessive, I've included akashic 
## from GCGLines, however the over head from running git on any larger 
## files at one of the higher log-levels would slow the program down
## well below the threshold of usability.

## That said, if you want a reversible play-by-play, the option is here.

about_gcg_logging() {
cat << EOF

Logging functions get called with events.
The log-level deems whether or not an event is significant enough to
be logged.

Events are logged as timestamped, individual items and conactenated
into a single events.log.gz file for the session, at the close of
the session.

The session_id is incremental, starting from 0 for each "ProjectName"
you use. If you end up starting a project over, or do not need or want
the logs for a project any more. You archive the project, or delete the
logs for that project with: 

	Either:
		~# gcgbuild -A "ProjectName" "VersionNumber" /path/to/archive
		~# gcgbuild --archive "ProjectName" "VersionNumber" /path/to/archive
	To archive your project.

	Or: 
		~# gcgbuild -C "ProjectName"
		~# gcgbuild --clear-log "ProjectName"
	To delete the log.

For each session in which logging is enabled:

1) The initial command, arguments, and other data are logged as:
	/var/log/gcg/projectname/session_ID/events/<timestamp>


command arguments and time of execution
a snapshot of the file system is taken
as soon as it is mounted.

	A snapshot consists of:
		The mount time of the editable image.
		A list of all of the files in the system, coupled with:
			sha256 and sha512 sums.
			Metadata about the files:
				Filename
				Size in bytes
				Owner
				Group
				Inode
				Permissions
				Filetype (-,c,d,b)
				Sticky Bit
				Last Access
				Last Modify

		A list of the entire directory tree.
		A list of installed packages via dpkg --list
		A list of hard links
		A list of soft links and their path resolutions.

EOF
}




snapshot_edit_image() {
    if [ "$log_level" != "none" ]; then
        if [ -f /var/log/gcg/$project_name/$session_id/init-fs-snapshot.txt ]; then
            find . -type f -print0 | xargs -0 sha512sum > /var/log/gcg/end-fs-snapshot.txt && \
            find / >> /var/log/gcg/end-fs-tree.txt

            su - -c mkdir -p /var/log/gcg && \
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

log_commands() {

	$@ >> /var/log/gcg/$session_id/events/
}

log_event() {
	event_id=""
	event_name=""
	event_type=""
	event_start=""
	event_stop=""
	event_success=""
	event_details=""
	return 0;
}

log_session() {
	session_id=""
	session_start=""
	session_stop=""
	session_events=( )
	session_start_image=""
	session_final_image=""
	return 0;
}

log_image_state() {
	image_name=""
	image_version=""
	image_manifest=""
	image_previous_manifests=""
	return 0;
}

log_notes() {
	notes_are_important=""
	crazy_ideas=""
	good_ideas=""
	task_lists=""
	mistakes=""
	return 0;
}