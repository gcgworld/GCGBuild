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
rfkill block all

## 0) Set variables
USERNAME=$(getent passwd 1000 | grep -oP "^\w+")
STRAP_DIR=$(dirname $0)
CONFIG_DIR=$STRAP_DIR/config
INET_IFACE="eth0"
SSH_SERVER_PORT=40001
FAUX_ROOT="ceo"
PASSWORD="ohyouapowerrangerfosho"
LAN_IP=$(ifconfig $INET_IFACE | grep -P "inet addr" | grep -oP "addr:\S+" | grep -oP "([0-9+]+.){3}[0-9]+")
LAN_RANGE=$(echo $LAN_IP | grep -oP "([0-9]+.){3}")0/24

## 1) Run gsettings so you can move around.
$STRAP_DIR/gcg-gsettings.sh

## 2) Copy config files into place.
cp $CONFIG_DIR/adduser.conf /etc/adduser.conf
cp $CONFIG_DIR/avahi-daemon.conf /etc/init/avahi-daemon.conf
cp $CONFIG_DIR/init-cups.conf /etc/init/cups.conf
cp $CONFIG_DIR/etc-default-grub /etc/default/grub
cp $CONFIG_DIR/host.conf /etc/host.conf
cp $CONFIG_DIR/host.allow /etc/hosts.allow && \

cp $CONFIG_DIR/host.deny /etc/hosts.deny && \

cp $CONFIG_DIR/limits.conf /etc/security/limits.conf
cp $CONFIG_DIR/modprobe.d-GCG.conf /etc/modprobe.d/GCG.conf
cp $CONFIG_DIR/securetty /etc/securetty && \
chown root:root /etc/securetty && \
chmod 600 /etc/securetty
cp $CONFIG_DIR/sshd_config /etc/ssh/sshd_config
cp $CONFIG_DIR/sysctl.conf /etc/sysctl.cnf
sysctl -p


## 3) Configure /etc/fstab
mount -o remount,rw,nosuid,nodev,noexec,relatime /tmp
mount -o remount,rw,relatime,data=ordered /var
mount -o remount,rw,nosuid,nodev,noexec,relatime /var/tmp
mount -o remount,rw,relatime,data=ordered /var/log
mount -o remount,rw,relatime,data=ordered /var/log/audit
mount -o remount,rw,nodev,relatime,data=ordered /home
mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime /run/shm

## 4) Ensure sticky bit on all world writable devices.
if [ "$( df --local -P | awk{'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type -d\( -perm -0002 -a ! -perm -0001\) 2>/dev/null )" != "" ]; then
	df --local -P | awk{'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type -d -perm -0002 2>/dev/null
fi

## No world writable files
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002

## No unowned files
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser

## No ungrouped files/dirs
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup

## Audit SUID executables
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -4000

## Audit SGID executables
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -2000

## Make sure there's no one in /etc/shadow with a pword
cat /etc/shadow | awk -F: '($2 == "") { print $1 " no pword ")'

## 5) Install aide
rfkill unblock all
# Let the games begin.
apt-get update && \
apt-get install -y aide apparmor-utils auditd crony fail2ban ntp openssh-server syslog-ng tcpd unattended-upgrades && \
stop ssh && \
dpkg-reconfigure -plow unattended-upgrades && \
rfkill block all && \
aide --init && \
echo "0 5 * * * /usr/bin/aide --check" >> /etc/crontab

chown root:root /etc/motd
chmod 644 /etc/motd
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/crontab
chmod 600 /etc/crontab
chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow
chown root:root /etc/hosts.deny
chmod 644 /etc/hosts.deny
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config




## 6) Secure GRUB
chown root:root /boot/grub/grub.cfg
chmod og-rxw /boot/grub/grub.cfg

grub-mkpasswd-pbkdf2 | tee tmpfile && \
echo '
cat <<EOF
set superusers="$USERNAME"
password_pbkdf2 $USERNAME $(cat tmpfile | grep -P "PBKDF2.*")
EOF' >> /etc/grub.d/00_header && \
shred -uvzn 37 tmpfile && \
update-grub
passwd root

## 7) Configure apparmor
if [ "$(ps -eZ | egrep 'initrc' | egrep -vw 'tr|ps|egrep|bash|awk' | tr ':' ' ' | awk '{print $NF }')" != '' ]; then
	ps -eZ | egrep 'initrc' | egrep -vw 'tr|ps|egrep|bash|awk' | tr ':' ' ' | awk '{print $NF }' > /var/log/unconfined.daemon

## 8) Configure permissions



## 9) Upgrades
rfkill unblock all && \
sleep 5 && \
apt-get upgrade -y
apt-get autoremove
apt-get autoclean

## 10) Check for Heart Bleed and Shell Shock.
if [ $(openssl version -b | grep -oP "\d{4}") < 2015 ]
  then
    apt-get upgrade -y openssl libssl-dev && \
    apt-cache policy openssl libssl-dev
fi

if [ $(env i='() { :;}; echo vulnerable' bash -c "echo test" | grep "vulnerable") == "vulnerable" ]
    then
        apt-get install --only-upgrade bash
fi

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

for package in $(dpkg --list | grep -oP "ii\s+.*?\s" | grep -oP " \w+.*$" | grep -oP "\S+")
do
	dpkg --verify $package
done

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
apt-get purge -y pulseaudio
apt-get purge -y samba-common
apt-get purge -y samba-libs
apt-get purge -y sane-utils
apt-get purge -y simple-scan
apt-get purge -y system-config-printer-common
apt-get purge -y system-config-printer-gnome
apt-get purge -y software-properties-common
apt-get purge -y toshset
apt-get purge -y transmission-gtk
apt-get purge -y transmission-common
apt-get purge -y ttf-indic-fonts-core
apt-get purge -y ttf-punjabi-fonts
apt-get purge -y ubuntuone-client-data
apt-get purge -y update-notifier
apt-get purge -y update-notifier-common
apt-get purge -y uno-libs3




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


## 17) Configure IPTables.
# Only use -F followed by drop default if you have access.
# for remote start with `iptables -A -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Then add your rules, then add the DROP default
iptables -F
iptables -P INPUT DROP && \
^INPUT^FORWARD && \
^FORWARD^OUTPUT && \
iptables -A INPUT -i $INET_IFACE -p tcp -s $LAN_RANGE --dport $SSH_SERVER_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $INET_IFACE -p tcp --sport $SSH_SERVER_PORT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i $INET_IFACE -p tcp -m multiport --dports 80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $INET_IFACE -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp -o $INET_IFACE --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i $INET_IFACE --sport 53 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
sh -c "iptables > /etc/iptables.rules"
echo "pre-up iptables-restore < /etc/iptables.rules" >> /etc/network/interfaces

## 18) Disable root after writing settings as sudo can't echo >> root/owned/file
dpkg-statoveride --update --add root sudo 4750 /bin/su
passwd -l root && \

## 19) Personal Customizations
# mkdir ~/bin
# wget https://subdomain.domain.tld/path/to/my/scripts
# Eternal bash_history



## XX) Reconnect to network.
sudo rfkill unblock

## sudo dpkg -r --force-depends package ## This removes package.
## sudo dpkg -P --force-depends package ## This purges config & tmp files.

sudo update-rc.d -f apport remove && \
sudo apt-get purge -y apport && \
sudo update-rc.d -f avahi-cups-reload remove && \
sudo update-rc.d -f avahi-daemon remove && \
sudo apt-get purge -y avahi-daemon && \
sudo update-rc.d -f bluetooth remove && \
sudo apt-get purge -y bluetooth && \
sudo update-rc.d -f cups-browsed remove && \
sudo apt-get purge -y cups-browsed && \
sudo update-rc.d -f cups remove && \
sudo apt-get purge -y cups && \
sudo update-rc.d -f unicast-local-avahi remove && \
sudo apt-get purge -y whoopsie && \
sudo apt-get purge -y zeitgeist && \
sudo apt-get purge -y zeitgeist-core && \
sudo apt-get purge -y account-plugin-* && \
sudo apt-get purge -y aisleriot && \
sudo apt-get autoremove && \
sudo apt-get purge -y app-install-data-partner && \
sudo apt-get purge -y avahi-autoipd && \
sudo apt-get purge -y bluez-alsa && \
sudo apt-get purge -y cheese && \
sudo apt-get purge -y cups-bsd && \
sudo apt-get purge -y cups-ppdc && \
sudo apt-get purge -y cups-common && \
sudo apt-get purge -y cups-pk-helper && \ ## Come back to CUPS once we purge the remianing packages isolated dependencies.
sudo apt-get autoremove && \
sudo apt-get purge -y brltty && \ ## Sorry blind people who want to use my computer. :(
sudo apt-get purge -y deja-dup && \
sudo apt-get purge -y empathy && \
sudo apt-get purge -y empathy-common && \
sudo apt-get autoremove && \
sudo dpkg -r --force-depends cups-filters && \
sudo dpkg -r --force-depends cups-filters-core-drivers && \
sudo dpkg -P --force-depends cups-filters && \
sudo dpkg -r --force-depends bluez && \
sudo dpkg -P --force-depends bluez && \
sudo dpkg -r --force-depends cheese-common && \
sudo dpkg -P --force-depends cheese-common && \
sudo dpkg -r --force-depends bluez && \
sudo dpkg -P --force-depends bluez && \
sudo dpkg -r --force-depends evince && \
sudo dpkg -P --force-depends evince && \
sudo dpkg -r --force-depends evince-common && \
sudo dpkg -P --force-depends evince-common && \
sudo dpkg -r --force-depends evolution-data-server && \
sudo dpkg -r --force-depends evolution-data-server-common && \
sudo dpkg -r --force-depends evolution-data-server-online-accounts && \
sudo dpkg -r --force-depends foomatic-db-compressed-ppds && \
sudo dpkg -r --force-depends friendly-recovery && \ ## Keep this if you want help-when you boot into recovery-mode.
sudo dpkg -r --force-depends friends && \
sudo dpkg -r --force-depends friends-dispatcher && \
sudo dpkg -r --force-depends gedit && \
sudo dpkg -r --force-depends gedit-common && \
sudo dpkg -r --force-depends geoclue && \
sudo dpkg -r --force-depends geoclue-ubuntu-geoip && \
sudo dpkg -r --force-depends geoip-database && \
sudo dpkg -r --force-depends geoclue && \
sudo dpkg -r --force-depends ghostscript ghostscript-x && \
sudo dpkg -r --force-depends gnome-mahjongg gnome-mines gnome-orca gnome-sudoku gnomine && \
