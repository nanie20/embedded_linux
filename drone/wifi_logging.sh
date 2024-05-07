  GNU nano 6.2                                                                  wifi_logging.sh                                                                            
#!/bin/bash

# Function to get the wireless interface name
get_wireless_interface() {
    # Get the name of the wireless interface
    interface=$(ip -o link show | awk -F': ' '$2 !~ "lo|vir|wl|^[0-9]"{print $2; exit}')
    echo "$interface"
}

# Main loop to continuously monitor WiFi link quality and signal level
while true; do
    # Get wireless interface name
    wireless_interface=$(get_wireless_interface)

    # Get current timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Read WiFi link quality and signal level from /proc/net/wireless
    wireless_info=$(cat /proc/net/wireless | grep wlp1s0)  # Adjust interface name as needed

    # Parse relevant data from wireless_info
    link_quality=$(echo "$wireless_info" | awk '{print $3}')
    signal_level=$(echo "$wireless_info" | awk '{print $4}')
    
    # Print the values to check if they are correct
    echo "Link Quality: $link_quality"
    echo "Signal Level: $signal_level"
    echo "Timestamp: $timestamp"


    # Insert data into SQLite database
    sqlite3 logWifi.db "INSERT INTO wifi_info (Link_quality, Signal_level, Timestamp) VALUES ($link_quality, $signal_level, '$timestamp');"

    # Sleep for a specified interval (e.g., 1 minute) before logging again
    sleep 10
done


