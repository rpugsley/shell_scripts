#!/bin/sh

fskcA="/root/fsck.sda"
fskcB="/root/fsck.sdb"
notification_email="example@email.com"


if [ "$(grep -o "clean" "$fskcA")" != "clean" ]
then
  msg="Check SDA, HDD is dirty\n$(date +%Y-%m-%d%t%H:%M:%S)"
  echo -e "From: \nTo:$notification_email \nSubject:$fskcA\n\n$msg"| msmtp -t
fi

if [ "$(grep -o "clean" "$fskcB")" != "clean" ]
then
  msg="Check SDB, HDD is dirty\n$(date +%Y-%m-%d%t%H:%M:%S)"
  echo -e "From: \nTo:$notification_email \nSubject:$fskcB\n\n$msg"| msmtp -t
fi

exit 0
