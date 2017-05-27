#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#                                                             #
# This is the part of GCG to adjust the setting for desktop.  #
# Edit as you see fit. This is not part of the hardening      #
# standard, except the first part which disables recording.   #
# Later we will remove the packages that run the recording,   #
# which will ensure in part the 'even if it's off, we will    #
# assume that it simply says it is off' philosophy.           #
#                                                             #
# "You call it paranoid, I call it prepared."                 #
#     - The great American poet ~ E-40 -                      #
#                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


# 1) Coerce big brother to turn around for a second.
#    Disable file system metadata recording.

gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.privacy remember-app-usage false 
gsettings set org.gnome.desktop.privacy hide-identity true


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#                                                             #
# Aesthetic preferences. These are wholly up to you. Edit as  #
# you like.                                                   #
#                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


# 2) Add workspaces because if you're running this, you're
#    probably the type of user that could use the real estate.

##  Desktop Settings
# Create four workspaces 2-vertical X 2-horizontal
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2
# Launcher hide and reduce icon size
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-hide-mode 1
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 28

# Nautilus Settings
# Courtesy of Grenade - https://gist.github.com/grenade/6363978#file-sane-gnome-settings-sh
gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'date_modified', 'owner', 'group', 'permissions']"
gsettings set org.gnome.nautilus.list-view default-zoom-level 'smallest'
gsettings set org.gnome.nautilus.preferences enable-delete true
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences sort-directories-first true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

# Make terminal off-white on mildly transparent black similar
# to OS X Apple-Terminal Pro style.
## This is fucked in 14.04.. but what do you expect for free.