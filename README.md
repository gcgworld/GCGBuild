# GCG

### Installation

**WARNING**: In it's current state, it is ***SUPER*** *easy* to fuck up your system. Do not run outside of a virtual machine until it says right here: where this message will become where this message was, that container support has been added... you know LXC/LXD/LXCFS, Docker... Or OpenVZ, Linux-VServer, FreeBSD jails, AIX Workload Partitions, Solaris Containers, and the other OS-Level virtualization tools.

**THAT SAID**: Computers are kind of fun to mess with. When I was testing this during dev, if I made a mistake, I *usually* saw some strange things happen to my linux installation that I had never seen before. Don't break your important computing machine, but it's not a sin to break a computer, that's been set aside to break.

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

... You know.. If you want to.


### Packaging your ISO

**THE PRESENT:** Do this manually, like `isohybrid --<Some option.> --<Yet another option.> --<More> --<options.> --<So> --<many> --<options.> --<Dude!! WTF?> --<Seriously?> --<Oh yeah.> --<All> --<of> --<the> --<options.> /path/to/your/custom/image.iso`

**THE FUTURE**
Just tell the program to do it when it asks you too, and it will.
It can craft you an LVX image for Virtual Box, and I'm hoping someone can help me structure the logging info, so that it translates directly to the Dockerfile, Docker-Compose.yml format
that would be awesome.
create docker images as well, but my focus is really on a live
distro, stripped to the bare essentials; what I'm calling "The Ground". You know, a computer that belongs to you.

Not yet sure how much effort will be required for OSX/MacOS compatibiliy. I avoided heavy dependencies (like a real programming language, with 1 or more efficient, reasonable, easy to follow, formal processes, for creating larger applications) on purpose. This started as a "Get better with Bash" project.


### Configuration
Place the config files, and setup scripts you want to bring
with you in the jailpurse folder. It provides a quick way to
save all those years of getting things *just right*. You can
immediately start a live distro with configuration you want.


### Logging

It should just use syslog or rsyslog or one of the names on the endless list of existing solutions for this very common need/want. Anyone could tell you that.

So I built my own, because this is a learning exercise. And now every time I grep /var/log/auth.log, I'm going to silently praise the soul who made that action possible.

As far a programs logging information about themselves in general, what they do and what happens on the system when they run for the user to review to assist in determining the causes of states.. Well... ... I think it's good. I've been wrong before though.

I like it because I fuck up a lot, and I *always* to know
where, how, what, when, and figure out how to fix it.

If you don't want or need it,
it's easiliy disabled with a command line option, and doesn't
jump around so it's easy to nuke.


### Package Installtion/Removal

There are a two config files located in jailpurse/config-scripts/config-files where you can specify the packages you want, don't want. For Debian-based distros, they are extremely simple.
You place a command from apt (install, remove, purge, download) if you want to use apt, at the beginning of a line, followed by the package you want to effect, separated by a colon. If you want perfrom the task through dpkg it's the same syntax, with a d infront of the command (dremove, dpurge, dinstall), which is followed by the name of the package, separated by three colons.

You read that right, three colons.

Right now, it's really that simple and it works. Who would have thought with all that YAML and JSON, you could just use three fucking colons! This will most likely change when I move for more robust options, but I swear I will do my best to make sure it will be one find and replace. And will provide the script to do it. I actually care about you and shit.


### That's It

I don't have anymore information for you. Have fun and/or break stuff and/or win.
