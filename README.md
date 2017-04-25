# GCG

### Installation

##### Quick Start
`~$ git clone <path-to-repo>`
`~$ cd gcg-build `
Place the .iso of the image you would like to modify in: images/bases/
`~$ cp /path/to/image/you/want/to/edit/image.iso images/bases`
`~$ sudo ./gcgbuild.sh images/bases/image.iso`
Everything should be running.
Hack like nobody's watching. :)


Once you are finished and ready to exit the image, run:
`~# /root/jailpurse/gcg-edit-clean.sh

### Packaging your ISO
Just tell the program to do it when it asks you too, and it will.
It can craft you an LVX image for Virtual Box, and I'm hoping someone can help me structure the logging info, so that it translates directly to the Dockerfile, Docker-Compose.yml format
that would be awesome.
create docker images as well, but my focus is really on a live
distro, stripped to the bare essentials I need to code, and 
serve. So I'm mostly focused on a bootable drive with persistant 
storage. Choose the option to write it directly to a bootable 
drive.

I'm still working toward OSX/MacOS compatibiliy in addition to 
running on linux. It's gonna be a dirty job, but I'll do it if I
can ever get this firmwary password cracked on my macbook (can't
go to the apple store, nothing bad, but a long story.)



### Configuration
Place the config files, and setup scripts you want to bring
with you in the jailpurse folder. It provides a quick way to
save all those years of getting things *just right*. You can
immediately start a live distro with configuration you want.


### Logging

I think it's good, because I fuck up a lot, and I like to know
why, and figure out how to fix it. If you don't want or need it,
it's easiliy disabled with a command line option, and doesn't
jump around so it's easy to nuke.

### Package Installtion/Removal

There are a two config files located in jailpurse/config-scripts/config-files where you can specify the packages you want, don't want. For Debian-based distros, they are extremely simple.
You place a command from apt (install, remove, purge, download) if you want to use apt, at the beginning of a line, followed by the package you want to effect, separated by a colon. If you want perfrom the task through dpkg it's the same syntax, with a d infront of the command (dremove, dpurge, dinstall), which is followed by the name of the package, separated by a colon. Right now, it's really that simple and it works. Who would have thought with all that YAML and JSON, you could just use a fucking colon! This will most likely change when I move for more robust options, but I swear I will do my best to make sure it will be one find and replace. And will provide the script to do it. I actually care about you and shit.

### Hardening

The goal is to bring this up to, and then beyond the standards
set out in the CIS hardeding manual. My goal is that you should
be able to host a web service, doing financial transactions
with a 1000 customers a day, and work from the computer you're 
doing this from. People keep trying to talk to me about 'The Cloud' like it's magic. AWS is a shit show, docker is a nightmare
(currently, and serioiusly fellows no disrespect, it's a brilliant nightmare, and will be the future.)