#!/usr/local/bin/bash

# Define the email address to which the email should be sent
EMAIL="email@example.com"

# Define the location of the static DHCP release file
STATIC_DHCP_FILE="/var/dhcpd/etc/dhcpd.conf"

# Define the location of the new DHCP release file
NEW_DHCP_FILE="/var/log/dhcpd/latest.log"

# Define the subject of the email
SUBJECT="New DHCP Release Detected"

# Define the last line of the file
LAST_LINE=$(tail -n 1 "$NEW_DHCP_FILE")

# Create last line file
touch /tmp/last_match

while true; do
    # Check if the file has changed
    if ! cmp -s /tmp/last_match "$NEW_DHCP_FILE"; then # Use cmp instead of diff
        LAST_LINE=$(tail -n 1 "$NEW_DHCP_FILE")
        DHCP_MODE=$(echo "$LAST_LINE" | awk '{print $9}')
        if [ "$DHCP_MODE" == "DHCPOFFER" ]; then
            IP=$(echo "$LAST_LINE" | awk '{print $11}')
            MAC=$(echo "$LAST_LINE" | awk '{print $13}')
            ETH=$(echo "$LAST_LINE" | awk '{print $15}')
            if  ! grep -qi "$MAC" "$STATIC_DHCP_FILE"; then
		# Run the nmap command and store the output in a variable
		OUTPUT=$(nmap -sP "$IP")
		# Extract the hostname from the output using grep and cut
		HOSTNAME=$(echo "$OUTPUT" | grep -m 1 "Nmap scan report for" | cut -d " " -f 5)
                echo "$LAST_LINE" > /tmp/last_match
                BODY=`printf "A new DHCP release has been detected for an unknown device. The details are as follows:\n\nOn $(date)\nIP Address: $IP\nMAC Address: $MAC\nHostname: $HOSTNAME\n"`
                echo -e "$BODY"
                sleep 3
                python3 /root/sendmail.py -s "$SUBJECT" -a "$BODY"
            fi
        fi
    fi
done

