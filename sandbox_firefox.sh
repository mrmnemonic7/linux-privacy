#!/bin/bash
# By Mr Mnemonic 7 (C) 2022. MIT license.
# Integrated download/update, run Firefox in a privacy-oriented sandbox. Should be able to run multiple-instances.
# Run with: "AUTOUPDATE=y ./sandbox_firefox.sh" to check for and update to newer Firefox version.
# 2020-04-04 - v1.3 - Integrate Decentral Eyes

STARTPAGE="https://searx.prvcy.eu"

function update_firefox()
{
FFLANG=en-GB
FFARCH=64
FFCHANNEL=latest-ssl

VERSION=${VERSION:-$(wget --spider -S --max-redirect 0 "https://download.mozilla.org/?product=firefox-${FFCHANNEL}&os=linux${FFARCH}&lang=${FFLANG}" 2>&1 | sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')}

if [ -f "firefox-${VERSION}.tar.bz2" ]; then
	echo "Already have ${VERSION}"
fi

echo "Fetching Firefox ${VERSION}"

# Fetch latest firefox
echo -n "Fetching Firefox..."
wget -nv --no-clobber --continue --content-disposition 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-GB'
echo "Done"

if [ -d ./firefox/ ]; then
echo "Previous Firefox detected, deleting..."
rm -Rf firefox/
fi

echo -n "Extracting Firefox..."
tar jxf firefox-${VERSION}.tar.bz2
echo "Done"

echo "Integrating add-ons"
cd firefox/
mkdir -p distribution/extensions
cd distribution/extensions/

echo -n "* uBlock Origin..."
wget --quiet --no-clobber --continue "https://github.com/gorhill/uBlock/releases/download/1.45.3rc5/uBlock0_1.45.3rc5.firefox.signed.xpi" -O uBlock0@raymondhill.net.xpi
echo "Done"

#This is now an internal feature
#echo -n "* HTTPS Everywhere..."
#wget --quiet --no-clobber --continue "https://www.eff.org/files/https-everywhere-latest.xpi" -O https-everywhere-eff@eff.org.xpi
#echo "Done"

echo -n "* Decentral Eyes..."
wget --quiet --no-clobber --continue "https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi" -O jid1-BoFifL9Vbdl2zQ@jetpack.xpi
echo "Done"

cd ../../..
echo "Finished add-on integration"

}

echo "Sandbox Private Firefox v1.4"

if [ "${AUTOUPDATE}" == 'y' ]; then
update_firefox
fi

FFXPROFILE=ffx$RANDOM
echo "Profile: ${FFXPROFILE}"

PWD=$(pwd)
echo "Working from $PWD"
echo "Using profile: ${FFXPROFILE}"

# Is there already a profile?
if [ ! -d "${PWD}/${FFXPROFILE}" ]; then
echo "Creating new Firefox profile"
mkdir ${FFXPROFILE}/
firefox/firefox -CreateProfile "${FFXPROFILE} ${PWD}/${FFXPROFILE}"
cp user.js ${PWD}/${FFXPROFILE}/
sed -i -- "s|FFXCACHE|cache-$FFXPROFILE|g" ${PWD}/${FFXPROFILE}/user.js
else
echo "That profile already exists. Something went wrong last time."
exit
fi

mkdir -p /tmp/cache-${FFXPROFILE}/

if [ "${PRIVATE}" == 'y' ]; then
echo "Launching Private Firefox"
firefox/firefox -private-window -profile "${PWD}/${FFXPROFILE}" ${STARTPAGE}
else
echo "Launching Firefox"
firefox/firefox -profile "${PWD}/${FFXPROFILE}" ${STARTPAGE}
fi

echo "Cleaning up ${FFXPROFILE}"
rm -Rf ${FFXPROFILE}/

echo "Cleaning up cache at /tmp/cache-${FFXPROFILE}"
rm -Rf /tmp/cache-${FFXPROFILE}/

exit
