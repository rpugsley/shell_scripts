#!/bin/sh
notification_email="example@email.com"

msg="OpenVPN got a new connection\nIs it you?\n\n$(date +%Y-%m-%d%t%H:%M:%S) on $1"
echo -e "From: \nTo:$notification_email \nSubject:Open Connect VPN\n\n$msg"| msmtp -t

exit 0
