#!/bin/bash

## If you're reading file-lists into rm -rf, double check that your
## list doesn't have files... that are directories in it.

## Context: Live Linux instance on top of recovery target.
## Target is mounted and unencrypted. No significant hurdles.

if [ $# -eq 0 ] || [ -z $1 ]; then
    echo "Usage: dpkg-info-recovery <mount point of target disk>"
    echo "i.e. dpkg-info-recovery /media/$USER/TARGET_DRIVE_NAME";
    exit 1;
fi

# Assumes drive is mounted for now. Hopefully I'll never
# have to reuse this script.

DRIVE_NAME=$1
DEST=/media/$USER/$DRIVE_NAME

# Let the games begin.

## Build the list of files we may need to recover.
for f in $(ls $DEST/var/lib/dpkg/info/ | grep -P ".list$")
do
	cat $f >> ~/file.list
done

## Iterate through the list of candidates for recovery
for f in $(cat ~/file.list)
do
	# If item exists and is a directory.
	if [ -d $f ]; then
		if [ -d $DEST$f ]; then
			echo "$DEST$f already existson target.."
		else
			mkdir -pv $DEST$f
		fi
	fi
	# If item exists and is regular file.
	if [ -f $f ]; then
		if [ -f $DEST$f ]; then
			echo "$DEST$f already existson target.."
		else
			cp -v $f $DEST$f
		fi
	fi
	# If file exists and is a link
	if [ -L $f ]; then
		# Determine if item is a hard link
		find / -inum $(ls -li $f | grep -oP "^\d+") 2>/dev/null >> ~/test_link.txt
		if [ $(wc -l ~/test_link.txt) -gt 1 ]; then
			echo "$f is a hard link to $(cat ~/test_link.txt)"
			echo "Moving on."
			cat /dev/null > ~/test_link.txt
		# If it's not a hard link it's a symlink we can fuck with.
		else
			# Get location of realfile
			real_f=$(readlink -e $f)
			# Check to see if it's on the destination drive.
			if [ -f $DEST$real_f ]; then
				echo "$DEST$real_f already exists on target.."
				# Check to see that the soft link exists.
				if [ -L $DEST$f ]; then
					echo "$DEST$real_f already exists on target.."
				# If it does not, create the link.
				else
					ln -s -v $DEST$real_f $DEST$f
				fi
			# If real file DNE on the destination drive.
			# Create it.
			else
				cp -v $real_f $DEST$real_f
				# If the symbolic link already exists
				if [ -L $DEST$f ]; then
					# Symlinks are strings not inode refs..
					# We're chill.
					echo "DEST$f already exists on target.."
				else
					# Create the symbollic link
					ln -s -v $DEST$real_f $DEST$f
				fi
			fi
		fi
	fi
	cat /dev/null > ~/test_link.txt
done
rm ~/file_test.txt ~/test_link.txt
echo "Done: If you used this because you had to, I hope it turns up roses. For real. Good luck."