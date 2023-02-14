#!/bin/bash

echo -n "Updating PGL Yoyo Adblock list..."
curl -s "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&startdate%5Byear%5D=2000&mimetype=plaintext" -o /etc/dnsmasq.d/adblock.conf
echo "Done"

echo -n "Updating someonewhocares super list..."
curl -s https://someonewhocares.org/hosts/hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | grep -v '^\\' | grep -v '\\$' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort | awk '{print "address=/" $1 "/127.0.0.1"}' > /etc/dnsmasq.d/superlist.conf
echo "Done"

echo "Please remember to restart dnsmasq for these updates to take effect"
