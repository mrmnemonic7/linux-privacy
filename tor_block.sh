#!/bin/sh

echo -n "Blocking all external non-tor traffic"
iptables -F
iptables -P OUTPUT DROP
iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT
iptables -P INPUT DROP
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 
echo "Done"
