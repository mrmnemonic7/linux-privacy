#!/bin/bash

WLAN=${1:-wlan0}
#Get this from the environment instead.
#DYNIP=y
IPADDR=192.168.1.50
IPROUTE=192.168.1.1

echo "WiFi Connect"

echo -n "Dropping connection"
killall dhclient &> /dev/null
killall wpa_supplicant
ifconfig ${WLAN} down
ifconfig ${WLAN} up
echo "Done"

echo -n "Negotiating WPA..."
wpa_supplicant -B -t -i ${WLAN} -c /etc/wpa_supplicant/wpa_supplicant.conf -f /var/log/wpa.log
sleep 5
echo "Done"

if [ "${DYNIP}" == 'y' ]; then
echo -n "Requesting IP address..."
dhclient ${WLAN} &> /dev/null
else
echo -n "Setting manual IP address and default route..."
ifconfig ${WLAN} ${IPADDR}
route add default gw ${IPROUTE}
fi
echo "Done"

echo "Update the DNS records now?"
read -p "[y/n] :" response

if [ "${response}" == 'y' ]; then
echo -n "Updating DNS resolver..."
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
echo "Done"
fi

echo "Okay, we're good"

exit
