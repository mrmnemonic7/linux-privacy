#!/bin/bash

EMAIL="me@mydomain.com"

# Find out our network card driver
NETWORK_DEVICE=$(route | grep '^default' | grep -o '[^ ]*$')

# Find out our IP address
IP_ADDRESS=$(ifconfig ${NETWORK_DEVICE} | grep "inet " | awk -F'[: ]+' '{ print $4 }')

# Find out our hostname
HOSTNAME=$(hostname)

# Get date and time
TIMESTAMP=$(date +%Y%m%d%H%M)

# Send it
mail -s "Started: ${HOSTNAME} at ${IP_ADDRESS}" "${EMAIL}" <<\EOF
Hostname: ${HOSTNAME}
IP Address: ${IP_ADDRESS}
Time: ${TIMESTAMP}

Regards,
Your Friendly Neighbourhood Boot Notification Script
EOF
