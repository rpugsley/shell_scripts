#!/bin/bash

# Set the threshold temperature in Celsius
THRESHOLD=80

# Set the email address to send the alert
EMAIL="your_email@example.com"

# Set the timeout duration in seconds
TIMEOUT=900

# Initialize the last email time to zero
LAST_EMAIL=0

# Define the log file
LOGFILE=/var/log/temp_check.log

# Create the log file if it does not exist
touch /var/log/temp_check.log

# Run the script indefinitely
while true; do
  # Get the current time in seconds since epoch
  NOW=$(date +%s)

  # Check if the timeout has elapsed since the last email
  if [ $(($NOW - $LAST_EMAIL)) -ge $TIMEOUT ]; then
    # Get the current CPU temperature of all 4 cores using sensors command
    TEMP1=$(sensors | awk '/Core 0/ {print $3}' | sed 's/+//;s/°C//')
    TEMP2=$(sensors | awk '/Core 1/ {print $3}' | sed 's/+//;s/°C//')
    TEMP3=$(sensors | awk '/Core 2/ {print $3}' | sed 's/+//;s/°C//')
    TEMP4=$(sensors | awk '/Core 3/ {print $3}' | sed 's/+//;s/°C//')

    # Round the temperature values to the nearest integer using printf command
    TEMP1=$(printf "%.0f" $TEMP1)
    TEMP2=$(printf "%.0f" $TEMP2)
    TEMP3=$(printf "%.0f" $TEMP3)
    TEMP4=$(printf "%.0f" $TEMP4)

    # Compare the temperature of each core with the threshold and send an email if any of them is higher
    if [ $TEMP1 -gt $THRESHOLD ] || [ $TEMP2 -gt $THRESHOLD ] || [ $TEMP3 -gt $THRESHOLD ] || [ $TEMP4 -gt $THRESHOLD ]; then
      echo "CPU temperature is above the threshold of $THRESHOLD°C. \nThe temperature of each core is: Core 0: $TEMP1°C, Core 1: $TEMP2°C, Core 2: $TEMP3°C, Core 3: $TEMP4°C" | mail -s "CPU Temperature Alert" $EMAIL
      # Update the last email time to the current time
      LAST_EMAIL=$NOW
      # Log the email alert
      logger -s "CPU temperature is above the threshold of $THRESHOLD°C. Sending email alert to $EMAIL" 2>&1 >> $LOGFILE
      # Print the email alert to the foreground
      echo "CPU temperature is above the threshold of $THRESHOLD°C. Sending email alert to $EMAIL"
    fi
    # Log the temperature values of each core
    logger -s "Core 0: $TEMP1°C, Core 1: $TEMP2°C, Core 2: $TEMP3°C, Core 3: $TEMP4°C" 2>&1 >> $LOGFILE
    # Print the temperature values of each core to the foreground
    echo "Core 0: $TEMP1°C, Core 1: $TEMP2°C, Core 2: $TEMP3°C, Core 3: $TEMP4°C"
  fi
  # Wait for one minute before the next check
  sleep 60
done
