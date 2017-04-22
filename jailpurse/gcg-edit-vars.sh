#!/bin/bash

## Edit-Mode Variables

INET_IFACE="eth0"
SSH_SERVER_PORT=34543
SSH_SERVER_PID=""
USER="GCG"
PASSWORD="ohyouapowerrangerfosho"
LAN_IP=$(ifconfig $INET_IFACE | grep -P "inet addr" | grep -oP "addr:\S+" | grep -oP "([0-9+]+.){3}[0-9]+")
LAN_RANGE=$(echo $LAN_IP | grep -oP "([0-9]+.){3}")0/24