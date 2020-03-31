#!/bin/bash

UPDATE_FIREWALL=n
UFS=' '
TOR_PATH=$(whereis tor | awk '{print $4}')
read -a strarr <<< "$TOR_PATH"
for val in "${strarr[@]}"; do
	if [[ "${val}" == *"etc"* ]]; then
		TOR_LOC=${val}
		break;
	fi
	echo "Error finding Tor"
	exit
done

echo "Found tor in ${TOR_LOC}."
# echo "Modifying ${TOR_LOC}/torrc"
ALREADY_THERE=$(grep "AutomapHostsOnResolve" ${TOR_LOC}/torrc | wc -l)
if [ "${ALREADY_THERE}" -lt 1 ]; then
echo -n "Updating ${TOR_LOC}/torrc..."
echo "DNSPort 9053" >> ${TOR_LOC}/torrc
echo "AutomapHostsOnResolve 1" >> ${TOR_LOC}/torrc
echo "AutomapHostsSuffixes .exit,.onion" >> ${TOR_LOC}/torrc
echo "Done"
fi

if [ "${UPDATE_FIREWALL}" == 'y' ]; then
echo -n "Updating firewall..."
iptables -t nat -A OUTPUT -p TCP --dport 53 -j DNAT --to-destination 127.0.0.1:9053
iptables -t nat -A OUTPUT -p UDP --dport 53 -j DNAT --to-destination 127.0.0.1:9053
echo "Done"
fi

