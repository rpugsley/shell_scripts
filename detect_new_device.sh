#!/bin/sh

# script to detect new dhcp lease

# this will be called by dnsmasq everytime a new device is connected
# with the following arguments
# $1 = add | old
# $2 = mac address
# $3 = ip address
# $4 = device name

known_mac_addr="/etc/config/dhcp"
notification_email="example@email.com"

#Convert MAC to uppercase                   
mac=$(echo "$2" | awk '{print toupper($0)}')   

# check if the mac is in known devices list
grep -q "$mac" "$known_mac_addr"                                                                                                                 
unknown_mac_addr=$?     


if [ "$unknown_mac_addr" != 0 ]; then
    if [ "$1" == "add" ] ; then
	msg="New device on `uci get system.@system[0].hostname`.`uci get dhcp.@dnsmasq[0].domain` $*"
	echo `date` $msg >> /root/unknown_macs
	# encode colon (:) and send email
	sed -i 's/:/-/g' "$msg"
	echo -e "From: \nTo:$notification_email \nSubject:DHCP\n\n$msg" | msmtp "$notification_email"
	fi
fi

exit 0
