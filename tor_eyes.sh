#!/bin/bash

FIVEEYE="{au},{nz},{us},{ca},{gb}"
FOURTEEN="{be},{dk},{fr},{de},{it},{nl},{no},{es},{se}"
MIDEAST="{af},{kz},{kg},{tj},{tm},{uz},{ir}"
EXTRA="{kp},{kr}"

echo "Tor Multi-Eyes blocker"

if [ "$1" == "" ] || [ $# -gt 1 ]; then
echo "Please specify level 1,2 or 3"
echo "Level 1: Five Eyes"
echo "Level 2: Fourteen Eyes"
echo "Level 3: Includes Level 2 plus Middle East"
echo "Level 4: Includes Level 3 plus other nasties"
exit
else
    LEVEL=$1
    case ${LEVEL} in
        "1")
            echo "Processing Level 1"
            BLOCKLIST="${FIVEEYE}"
            ;;
        "2")
            echo "Processing Level 2"
            BLOCKLIST="${FIVEEYE},${FOURTEEN}"
            ;;
        "3")
            echo "Processing Level 3"
            BLOCKLIST="${FIVEEYE},${FOURTEEN},${MIDEAST}"
            ;;
        "4")
            echo "Processing Level 4"
            BLOCKLIST="${FIVEEYE},${FOURTEEN},${MIDEAST},${EXTRA}"
            ;;
        *)
        echo "Unknown level specified"
        exit
        ;;
    esac
fi

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

echo "GeoIPExcludeUnknown 1" >> ${TOR_LOC}/torrc

#Investigate how important this is
#if [ "${PARANOID}" == "1" ]; then
#echo "ExcludeNodes {il},{kr},{kp},{ir}" >> ${TOR_LOC}/torrc
#fi

echo "ExcludeExitNodes ${BLOCKLIST}" >> ${TOR_LOC}/torrc
echo "NodeFamily ${BLOCKLIST}" >> ${TOR_LOC}/torrc
echo "StrictNodes 1" >> ${TOR_LOC}/torrc
echo "PathsNeededToBuildCircuits 0.95" >> ${TOR_LOC}/torrc

echo "Done"
else
echo "Already processed."
fi

echo "Tor should now be restarted for the changes to take effect."
exit
