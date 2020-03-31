#!/bin/bash -e
# Generate checksums, perform rsync and confirm checksums.

SRC=${1}
DEST=${2}
CWD=$(cwd)

echo -n "Generating checksums..."
find . -type f -exec md5 "{}" + > ${SRC}/checksums.lst
echo "Done"

echo -n "Performing rsync..."
rsync -av -P ${SRC} ${DEST}/
echo "Done"

echo -n "Verifying checksums..."
cd ${DEST}/
md5sum -c ./checksums.lst | grep -v OK
cd ${CWD}
echo "Done"
