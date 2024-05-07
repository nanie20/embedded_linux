#!/bin/bash

interface=$(ip -o link show | awk -F': ' '$2 !~ "lo|vir|wl|^[0-9]"{print $2; exit}')
# Main loop to continuously monitor WiFi link quality and signal level
while true; do
    echo $interface
    # Get wireless interface name
    wireless_interface=$(get_wireless_interface)

    # Get current timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Read WiFi link quality and signal level from /proc/net/wireless
    wireless_info=$(cat /proc/net/wireless)  # Adjust interface name as needed

    # Parse relevant data from wireless_info
    interface=$(echo "$wireless_info" | awk '{print $1}')
    link_quality=$(echo "$wireless_info" | awk '{print $3}')
    signal_level=$(echo "$wireless_info" | awk '{print $4}')
    
    # Print the values to check if they are correct
    echo "Interface: $interface"
    echo "Link Quality: $link_quality"
    echo "Signal Level: $signal_level"
    echo "Timestamp: $timestamp"


    # Insert data into SQLite database
    sqlite3 LogWifi.db "INSERT INTO wifi_info (Link_quality, Signal_level, Timestamp) VALUES ($link_quality, $signal_level, '$timestamp');"

    # Sleep for a specified interval (e.g., 1 minute) before logging again
    sleep 5
done


