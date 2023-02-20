#!/bin/sh

echo -n "Blocking all external non-tor traffic"
iptables -F OUTPUT
iptables -A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT
iptables -A OUTPUT -o 127.0.0.1 -j ACCEPT
iptables -P OUTPUT DROP
echo "Done"

iptables -L -v
