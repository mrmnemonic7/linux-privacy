#!/bin/bash

echo -n "Updating PGL Yoyo Adblock list..."
wget "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&startdate%5Bday%5D=01&startdate%5Bmonth%5D=01&startdate%5Byear%5D=2000&mimetype=plaintext" -O /etc/dnsmasq.d/adblock.conf
echo "Done"
