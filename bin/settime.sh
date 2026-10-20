#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

while true; do
    # Fetch current Unix timestamp from WorldTimeAPI
    REAL_TIME=$(curl -s "http://worldtimeapi.org/api/timezone/Etc/UTC" | grep -o '"unixtime":[0-9]*' | grep -o '[0-9]*' || echo "")

    if [ -z "$REAL_TIME" ]; then
        echo "Error: Failed to fetch time from server. Retrying in 65 seconds..."
        sleep 65
        continue
    fi

    # Generate random offset in seconds (±12 hours = ±43200 seconds)
    # RANDOM gives 0-32767, so we scale to 0-86400 then subtract 43200
    OFFSET=$(((RANDOM * 86400 / 32768) - 43200))

    # Calculate new time
    NEW_TIME=$((REAL_TIME + OFFSET))

    # Set the system time using BSD date command
    # Format: MMDDhhmm[[CC]YY][.ss]
    NEW_DATE_STR=$(date -r $NEW_TIME '+%m%d%H%M%Y.%S')
    date $NEW_DATE_STR > /dev/null 2>&1

    sleep 65
done
