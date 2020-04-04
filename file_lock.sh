#!/bin/bash
# By Mr Mnemonic (C) 2020. MIT license.

if [ -z "$1" ]; then
echo "Choose either encrypt or decrypt"
exit
fi
CMD="$1"

if [ -z "$2" ]; then
echo "Please specify a file to process."
exit
fi
INFILE="$2"

if [ ! -f "${INFILE}" ]; then
echo "${INFILE} does not exist"
exit
fi

echo "Enter passphrase: "
read -s -p ":" MYKEY1
echo
echo "Confirm passphrase: "
read -s -p ":" MYKEY2
echo

if [ "${MYKEY1}" != "${MYKEY2}" ]; then
echo "Passphrases do not match."
exit
fi

case "$CMD" in
	encrypt)
	echo -n "${MYKEY1}" | openssl enc -aes-256-cbc -salt -in "${INFILE}" -out "${INFILE}".enc -pass stdin
	echo "Output ${INFILE}.enc"
	;;
	decrypt)
	OUTFILE="${INFILE%.*}"
	echo -n "${MYKEY1}" | openssl enc -aes-256-cbc -d -in "${INFILE}" -out "${OUTFILE}" -pass stdin
	echo "Output ${OUTFILE}"
	;;
esac

exit
