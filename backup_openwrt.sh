#!/bin/sh

# Specify the backup directory
backup_dir="/root/backup"

# Get the most recent backup file
most_recent_file=$(ls -t "$backup_dir"/*.tar.gz | head -n 1)

# Calculate the hash of the most recent backup file
most_recent_hash=$(sha256sum "$most_recent_file" | awk '{print $1}')

# Create a backup file
backup_file="${backup_dir}/backup-${HOSTNAME}-$(date +%F).tar.gz"
sysupgrade -b "$backup_file"

# Calculate the hash of the newly created backup file
new_file_hash=$(sha256sum "$backup_file" | awk '{print $1}')

# Compare hashes
if [ "$most_recent_hash" == "$new_file_hash" ]; then
#    echo "MR $most_recent_hash = $new_file_hash NF"
    echo "Hashes match. Deleting $backup_file."
    rm -f "$backup_file" 
else
#    echo "MR $most_recent_hash != $new_file_hash NF"
    echo "Hashes do not match. Keeping $backup_file."
fi

# Log rotation: Keep only the 30 most recent backup files
find "$backup_dir" -name "*.tar.gz" -type f | sort -r | tail -n +31 | xargs rm
