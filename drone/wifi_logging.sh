#!/bin/bash

# Function to get the wireless interface name
get_wireless_interface() {
    ip -o link show | awk -F': ' '$2 ~ /^wl/{print $2; exit}'
}

interface=$(get_wireless_interface)

# Main loop to continuously monitor WiFi link quality and signal level
echo "Detected Interface: $interface"

# Get current timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Read WiFi link quality and signal level from /proc/net/wireless
wireless_info=$(grep "$interface" /proc/net/wireless)

# Ensure wireless_info is not empty
if [ -z "$wireless_info" ]; then
    echo "No wireless info found for interface $interface"
    sleep 5
    continue
fi

# Parse relevant data from wireless_info
link_quality=$(echo "$wireless_info" | awk '{print int($3)}')
signal_level=$(echo "$wireless_info" | awk '{print int($4)}')

# Print the values to check if they are correct
echo "Interface: $interface"
echo "Link Quality: $link_quality"
echo "Signal Level: $signal_level"
echo "Timestamp: $timestamp"

# Insert data into SQLite database
sudo sqlite3 LogWifi.db "INSERT INTO wifi_info (Link_quality, Signal_level, Timestamp) VALUES ('$link_quality', '$signal_level', '$timestamp');"

# Sleep for a specified interval (e.g., 1 minute) before logging again
sleep 5


