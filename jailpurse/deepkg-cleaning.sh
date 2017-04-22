#!/bin/bash
  ____________________________________________________________
 #]##########################################################|
 #|                                                         #|
 #|                   GCGLinux Prototype                    #|
 #|         Setting Up Your Dev-Box/Server on Metal         #|
 #|_________________________________________________________#|
 #]##########################################################]
   
## If you run your own shit, you're going to learn a lot while
## you get your ass kicked.


## -1) Run as root.



## 6) Secure GRUB
# chown root:root /boot/grub/grub.cfg
# chmod og-rxw /boot/grub/grub.cfg

# grub-mkpasswd-pbkdf2 | tee tmpfile && \
# echo '
# cat <<EOF
# set superusers="$USERNAME"
# password_pbkdf2 $USERNAME $(cat tmpfile | grep -P "PBKDF2.*")
# EOF' >> /etc/grub.d/00_header && \
# shred -uvzn 37 tmpfile && \
# update-grub
# passwd root

## 7) Configure apparmor
# if [ "$(ps -eZ | egrep 'initrc' | egrep -vw 'tr|ps|egrep|bash|awk' | tr ':' ' ' | awk '{print $NF }')" != '' ]; then
# 	ps -eZ | egrep 'initrc' | egrep -vw 'tr|ps|egrep|bash|awk' | tr ':' ' ' | awk '{print $NF }' > /var/log/unconfined.daemon

## 8) Configure permissions



## 9) Upgrades
# rfkill unblock all && \
# sleep 5 && \


## 11) Configure services
# ntp
# crony
# auditd
# rsyslog
# snort
# tripwire
# syslog-ng
# logrotate
# cron

# for package in $(dpkg --list | grep -oP "ii\s+.*?\s" | grep -oP " \w+.*$" | grep -oP "\S+")
# do
# 	dpkg --verify $package
# done

## 12) Create swap.
#swapon -s && \
#dd if=/dev/zero of=/swapfile bs=4M count=1000 && \
#mkswap /swapfile && \
#swapon /swapfile && \
## 7a) Make swap persistent
#echo "/swapfile swap swap defaults 0 0" >> /etc/fstab && \
## 7b) Set Swapiness
#echo 0 >> /proc/sys/vm/swappiness && \ 
#echo vm.swappiness = 0 >> /etc/sysctl.conf

## The thing is you will break apt
apt-get purge -y apport
apt-get purge -y avahi-daemon avahi-utils avahi-autoipd
apt-get purge -y cups
apt-get purge -y modemmanager
apt-get purge -y whoopsie
apt-get purge -y whoopsie-preferences
apt-get purge -y zeitgeist-core zeitgeist-datahub python-zeitgeist rhythmbox-plugin-zeitgeist zeitgeist
apt-get purge -y aisleriot gnome-mahjongg gnome-mines gnome-orca gnome-sudoku gnomine
apt-get purge -y app-install-data-partner
apt-get purge -y cheese
apt-get purge -y speech-dispatcher
apt-get purge -y libreoffice-*
apt-get purge -y telepathy-*
apt-get purge -y webbrowser-app
apt-get purge -y thunderbird
apt-get purge -y smbclient
apt-get purge -y webaccounts-extension-common
apt-get purge -y rhythmbox
apt-get purge -y remmina
apt-get purge -y shotwell
apt-get purge -y xul-ext-ubufox
apt-get purge -y sphinx-voxforge-*
apt-get purge -y alsa-base
apt-get purge -y alsa-utils
apt-get purge -y app-install-data
apt-get purge -y bluez
apt-get purge -y cheese-common
apt-get purge -y baobab
apt-get purge -y brltty
apt-get purge -y cups-filters
apt-get purge -y cups-filters-core-drivers
apt-get purge -y cups-browsed
apt-get purge -y cups-common
apt-get purge -y cups-daemon
apt-get purge -y cups-pk-helper
apt-get purge -y cups-browsed
apt-get purge -y cups-server-common
apt-get purge -y python-cups
apt-get purge -y python-cupshelpers
apt-get purge -y evince
apt-get purge -y evince-common
apt-get purge -y evolution-data-server-common
apt-get purge -y enchant
apt-get purge -y eog
apt-get purge -y example-content
apt-get purge -y file-roller
apt-get purge -y foomatic-db-compressed-ppds
apt-get purge -y gedit
apt-get purge -y gedit-common
apt-get purge -y geoclue
apt-get purge -y geoip-database ghostscript ghostscript-x printer-driver-pnm2ppa
apt-get purge -y gstreamer*
#apt-get purge -y kerneloops-daemon
apt-get purge -y krb5-locales
apt-get purge -y colord
apt-get purge -y gettext
apt-get purge -y im-config
apt-get purge -y linux-sound-base # A 0 byte package... hmm.
apt-get purge -y obex-data-server
apt-get purge -y poppler-data
apt-get purge -y popularity-contest
apt-get purge -y ppp
apt-get purge -y prin
apt-get purge -y pulseaudio
apt-get purge -y samba-common
apt-get purge -y samba-libs
apt-get purge -y sane-utils
apt-get purge -y simple-scan
apt-get purge -y system-config-printer-common
apt-get purge -y system-config-printer-gnome
apt-get purge -y software-properties-common
apt-get purge -y software-center-aptdaemon-plugins
apt-get purge -y toshset
apt-get purge -y transmission-gtk
apt-get purge -y transmission-common
apt-get purge -y ttf-indic-fonts-core
apt-get purge -y ttf-punjabi-fonts
apt-get purge -y ubuntuone-client-data
apt-get purge -y update-notifier
apt-get purge -y update-notifier-common
apt-get purge -u update-manager-core
apt-get purge -y uno-libs3

## For those tough to reach places
dpkg -P --force-depends libcups2:amd64
dpkg -P --force-depends libcupscgi1:amd64
dpkg -P --force-depends libcupsfilters1:amd64
dpkg -P --force-depends libcupsimage2:amd64
dpkg -P --force-depends libcupsmime1:amd64
dpkg -P --force-depends libcupsppdc1:amd64
dpkg -P --force-depends libfreerdp-plugins-standard
dpkg -P --force-depends system-config-printer-udev
dpkg -P libgutenprint2
dpkg -P printer-driver-c2esp 
dpkg -P printer-driver-foo2zjs
dpkg -P printer-driver-foo2zjs-common 
dpkg -P printer-driver-min12xxw 
dpkg -P printer-driver-pnm2ppa 
dpkg -P printer-driver-ptouch 
dpkg -P printer-driver-pxljr 
dpkg -P printer-driver-sag-gdi 


## XX) Remove unecessary users from /etc/passwd
# games
# lp (Who uses a printer anymore?)
# news
# list
# usbmux
# kernoops
# irc
# gnats
# hplip
# saned (saned is the SANE (Scanner Access Now Easy) daemon that allows remote clients to access image acquisition devices available on the local host.
#        ^ Don't need or want that.


## 16) Install and configure Snort.
##     The package from the debian repo is 3 or 4 versions behind the current.
##     You will need to get it from the snort dudes.

INET_IFACE="wlan0"
SSH_SERVER_PORT=22
## 17) Configure IPTables.
# Only use -F followed by drop default if you have access.
# for remote start with `iptables -A -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Then add your rules, then add the DROP default



## 19) Personal Customizations
# mkdir ~/bin
# wget https://subdomain.domain.tld/path/to/my/scripts
# Eternal bash_history



