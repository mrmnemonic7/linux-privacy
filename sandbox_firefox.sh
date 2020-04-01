#!/bin/bash
# Integrated download/update, run Firefox in a privacy-oriented sandbox. Should be able to run multiple-instances.
# Run with: "AUTOUPDATE=y ./sandbox_firefox.sh" to check for and update to newer Firefox version.

STARTPAGE="https://start.duckduckgo.com"

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

# Fetch uBlock Origin
# TODO - implement this properly
#echo -n "Fetching uBlock Origin..."
#wget -nv --no-clobber --continue "https://github.com/gorhill/uBlock/releases/download/1.18.0/uBlock0_1.18.0.firefox.xpi"
#echo "Done"

if [ -d ./firefox/ ]; then
echo "Previous Firefox detected, deleting..."
rm -Rf firefox/
fi

echo -n "Extracting Firefox..."
tar jxf firefox-${VERSION}.tar.bz2
echo "Done"

echo -n "Integrating uBlock Origin..."
cd firefox/
mkdir -p distribution/extensions
cd distribution/extensions/
wget --quiet --no-clobber --continue "https://github.com/gorhill/uBlock/releases/download/1.25.3rc0/uBlock0_1.25.3rc0.firefox.signed.xpi" -O uBlock0@raymondhill.net.xpi
cd ../../..
echo "Done"

}

echo "Sandbox Private Firefox v1.1"

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
