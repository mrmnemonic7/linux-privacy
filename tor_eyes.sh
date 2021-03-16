#!/bin/bash

if [ -z $1 ]; then
EYES=5
else
EYES=$1
fi

# Prevent certain country nodes from being used
PARANOID=1

echo "Tor Multi-Eyes blocker"
echo "Searching for Tor..."
#TOR_LOC=$(whereis tor | awk '{print $4}')
TOR_LOC=$(which tor)
if [ -z ${TOR_LOC} ]; then
    echo "Error finding Tor";
    exit
else
	echo "Tor location: ${TOR_LOC}"
    if [[ "${TOR_LOC}" == *"/usr/local"* ]]; then
		#echo "Tor found in /usr/local/etc/"
		TOR_LOC=/usr/local/etc/tor
    else
		#echo "Tor found in /etc"
		TOR_LOC=/etc/tor
    fi

fi
if [ -f ${TOR_LOC}/torrc ]; then
echo "Found tor config in ${TOR_LOC}."
fi

ALREADY_THERE=$(grep "Tor Multi-Eyes Blocker" ${TOR_LOC}/torrc | wc -l)
if [ "${ALREADY_THERE}" -lt 1 ]; then
#echo "Modifying ${TOR_LOC}/torrc"
echo -n "Updating ${TOR_LOC}/torrc..."
echo "" >> ${TOR_LOC}/torrc
echo "# Tor Multi-Eyes Blocker" >> ${TOR_LOC}/torrc

echo "StrictNodes 1" >> ${TOR_LOC}/torrc
echo "GeoIPExcludeUnknown 1" >> ${TOR_LOC}/torrc

if [ "${PARANOID}" == "1" ]; then
echo "ExcludeNodes {il},{kr},{kp}" >> ${TOR_LOC}/torrc
fi

if [ "${EYES}" == "14" ]; then
echo "Excluding 14 eyes..."
echo "# Exclude 14 Eyes" >> ${TOR_LOC}/torrc
echo "ExcludeExitNodes {au},{nz},{us},{ca},{gb},{be},{dk},{fr},{de},{it},{nl},{no},{es},{se}" >> ${TOR_LOC}/torrc
echo "NodeFamily {au},{nz},{us},{ca},{gb},{be},{dk},{fr},{de},{it},{nl},{no},{es},{se}" >> ${TOR_LOC}/torrc
else
echo "Excluding 5 eyes..."
echo "# Exclude 5 Eyes" >> ${TOR_LOC}/torrc
echo "ExcludeExitNodes {au},{nz},{us},{ca},{gb}" >> ${TOR_LOC}/torrc
echo "NodeFamily {au},{nz},{us},{ca},{gb}" >> ${TOR_LOC}/torrc
fi

echo "PathsNeededToBuildCircuits 0.95" >> ${TOR_LOC}/torrc

echo "Done"
else
echo "Already processed for 14 eyes"
fi

exit
