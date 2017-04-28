#!/bin/bash

## Wrapper functions for functions to pass events to log.
## Look into using:
## 		whowatch or acct


log_event() {
	event_name=""
	event_type=""
	event_start=""
	event_stop=""
	event_success=""
	event_details=""
	return 0;
}

log_session() {
	session_no=""
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