#!/bin/bash

## Setup persistant IPTables rule set.



iptables -F
iptables -P INPUT DROP && \
iptables -P OUTPUT DROP && \
iptables -P FORWARD DROP && \
iptables -A INPUT -p tcp -s $LAN_RANGE --dport $SSH_SERVER_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o -p tcp --sport $SSH_SERVER_PORT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT-p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp -o $INET_IFACE --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i $INET_IFACE --sport 53 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables-save > /etc/iptables.rules
echo "pre-up iptables-restore < /etc/iptables.rules" | tee /etc/network/interfaces
echo "All Done!"
exit 0