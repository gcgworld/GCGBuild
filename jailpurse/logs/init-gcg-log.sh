#!/bin/bash

## Variables written in during build setup, reset during host cleanup
project_name=""
session_id=0

## Log info for edit session is written here..
gcg_edit_session_log="/var/log/gcg/$project_name/$session_id"
mkdir -p $gcg_edit_session_log/session
mkdir -p $gcg_edit_session_log/events
mkdir -p $gcg_edit_session_log/manifests


## Create initial file-manifest
cd /
find / -exec ls -lia "{}" >> $gcg_edit_session_log/manifests/full_list \;
find / -type f -print0 | xargs -0 sha512sum > $gcg_edit_session_log/manifests/start-session.manifest










## Create end of session file-manifest
cd /
find / -type f -print0 | xargs -0 sha512sum > $gcg_edit_session_log/manifests/start-session.manifest
## Log folder is copied back to host when clean_image is called.