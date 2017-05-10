Program Flow:
	
	Automatic:
		intro_screen()
			# Bad options
				show_help()
			# Good options
				setup_logging_framework()
				check_for_dependencies()
					# Fail
						error_missing_dependecies()
						quit_gcgbuild()

		setup_host_logging_session()
		create_mount_dirs()
		mount_base_image()
		locate_image_squashfs()
		init_build_image()
		mount_fs()
		init_edit_fs()
		setup_guest_logging()
		setup_guest_networking()
		init_jailpurse()
		enter_edit_fs()
		...
		exit_edit_fs()
		enter_gcg_lines()
			# Yes
				gcg_lines()
				...
				exit_gcg_lines() 
		write_to_usb()
			# Yes
				select_disk()
			    format_disk()
			    wipe_disk()
			    	no_wipe()
			    	zero-out()
			    	mersenne_prime_twister()
			    create_partitions()
			    	single_partition()
			    	boot_and_persistence()
			    		write_boot_partition()
			    		write_persistence_partitions()
			    		encrypt_persistence()
			    			select_algorithm()
			    			create_key()
			    			encrypt()

		decision()
			# [0] Return to editing your image.
			#     !!WORKS!!
				-- enter_edit_context
				enter_edit_fs()
				------------------------
				-- loop
				decision()
				--
			# [1] Save your changes to your image to the ISO and keep working.
			#     !!WORKS!!
				-- clean_edit_fs
				clean_edit_fs_apt() 
				clean_edit_fs_tmp()
				import_edit_fs_logs()
				clean_edit_fs_logs()
				deactivate_edit_fs()
				------------------------
				-- save_custom_build
				init_build_image()
				write_new_image_manifest()
				build_new_image_fs()
				generate_new_image_checksums()
				generate_new_iso()
				------------------------
				-- clear_edit_fs
				deactivate_edit_fs()
				delete_edit_fs()
				delete_build_image()
				------------------------
				-- init_base
				create_mount_dirs()
				mount_base_image()
				locate_image_squashfs()
				mount_base_fs()
				------------------------
				-- init_edit_context
				init_edit_fs()
				init_edit_fs_logging()
				init_edit_fs_networking()
				stuff_jailpurse()
				------------------------
				-- enter_edit_context
				enter_edit_fs()
				------------------------
				-- loop
				decision()
				--

			# [2] Save your changes to your image to the ISO and work on another project.
			#     !!WORKS!!
				-- clean_edit_fs
				clean_edit_fs_apt()
				import_edit_fs_logs()
				clean_edit_fs_logs()
				clean_edit_fs_tmp()
				------------------------
				-- save_edit_fs
				deactivate_edit_fs()
				write_new_image_manifest()
				build_edit_fs()
				generate_new_image_checksums()
				generate_new_iso()
				------------------------
				-- clear_edit_fs
				deactivate_edit_fs()
				clear_edit_fs()
				clear_build_image()
				------------------------
				-- clear_project_mount
				unmount_base_fs()
				unmount_base()
				clear_base_fs()
				clear_base_image()
				------------------------
				-- load_new_project_base
				new_project_base_image()
				------------------------
				-- init_base
				create_mount_dirs()
				mount_base_image()
				locate_image_squashfs()
				mount_fs()
				------------------------
				-- init_edit_context
				init_build_image()
				init_edit_fs()
				init_edit_fs_logging()
				init_edit_fs_networking()
				jailpurse()
				------------------------
				-- enter_edit_context
				enter_edit_fs()
				------------------------
				-- loop
				decision()
				--

			# [3] Save your changes to your image to the ISO and quit.
			#     !!WORKS!!
				-- clean_edit_fs
				clean_edit_fs_apt()
				import_edit_fs_logs()
				clean_edit_fs_logs()
				clean_edit_fs_tmp()
				------------------------
				-- save_edit_fs
				deactivate_edit_fs()
				write_new_image_manifest()
				build_edit_fs()
				generate_new_image_checksums()
				generate_new_iso()
				------------------------
				-- clear_project_mount
				unmount_fs()
				unmount_base()
				clear_fs()
				clear_base_image()
				------------------------
				-- quit
				quit_gcgbuild()
				--

			# [4] Discard your changes and start over.
			#     !!WORKS!!
				-- discard changes
				deactivate_edit_fs()
				clear_edit_fs()
				clear_build_image()
				------------------------
				-- init_edit_context
				init_edit_fs()
				init_edit_fs_logging()
				init_edit_fs_networking()
				jailpurse()
				------------------------
				-- enter_edit_context
				enter_edit_fs()
				------------------------
				-- loop
				decision()
				--

			# [5]
				-- clear_edit_mount
				deactivate_edit_fs()
				clear_edit_fs()
				clear_build_image()
				------------------------
				-- clear_project_mount
				unmount_fs()
				unmount_base()
				clear_fs()
				clear_base_image()
				------------------------
				-- switch_projects
				select_new_base_image()
				select_new_custom_dir()
				------------------------
				-- create_mount_dirs
				create_base_mount_dir()
				create_fs_mount_dir()
				create_edit_fs_mount_dir()
				create_build_mount_dir()
				------------------------
				-- init_base
				mount_base_image()
				init_build_image()
				locate_image_squashfs()
				mount_fs()
				------------------------
				-- init_edit_context
				init_edit_fs()
				init_edit_fs_logging()
				init_edit_fs_networking()
				jailpurse()
				-- enter_edit_context
				enter_edit_fs()
				------------------------
				-- loop
				decision()
				--

			# [6]
				-- discard_changes
				deactivate_edit_fs()
				clear_edit_fs()
				clear_build_image()
				------------------------
				-- clear_project_mount
				unmount_fs()
				unmount_base()
				clear_fs()
				clear_base_image()
				------------------------
				-- quit
				quit_gcgbuild()
				--

			#[7]
				-- view_manual
				show_man_page_menu()
				display_man_page()
				------------------------
				-- loop
				decision()
				--

			#[8]
				-- enter_gcg_lines
				gcg_lines()
				...
				exit_gcg_lines()
				------------------------
				-- loop
				decision()
				--

			# [9]
				-- view_logs
				gcg_log_view()
				------------------------
				-- loop
				decision()
				--

			#[Q]
				-- warn_user
				inform_mounts_still_active()
				offer_nuke_tmp_files()
				------------------------
				-- quit
				quit_gcgbuild()
				--











Program Flow:
	Interactive:

Start:
	intro_screen()
		# Bad options
			show_help()
		# Good options
			setup_logging_framework()
			check_for_dependencies()
				# Fail
					error() ( missing_dependecies() )
					quit_gcgbuild()

	setup_host_logging_session()
		is_new_project()
			# Yes
				create_project_log()
			# No
				archive_last_version()
					# Yes
						get_project_vars()
						set_version_string()
						compress_last_version()
						store_last_version()
						increment_version()
					# No
						get_project_vars()

	check_base_image()
		# Fail
			error() ( invalid_base_image() )
			select_new_base_image() || quit_gcgbuild()
		# Pass
			create_mount_dirs()

	strip_trailing_dir_slash()
	confirm_cmd()
	
	select_new_base_image()
	archive_last_version()

	create_mount_dirs()
	mount_base_image()
	locate_image_squashfs()
	init_build_image()
	mount_fs()
	init_edit_fs()
	setup_guest_logging()
	setup_guest_networking()
	smuggle_in()
	enter_edit_fs()
	start_gcg_lines()
	write_new_image_manifest()
	build_new_image_fs()
	generate_new_image_checksums()
	generate_new_iso()

	unmount_guest_fs()
	unmount_guest_base_image()
	clean_up_guest_files()
	write_to_usb()
	decision()
	load_edit_fs()
	load_tools_into_image()
	edit_fs()
	discard_changes()
	save_image()
	quit_gcgbuild()
	main()