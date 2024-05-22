#!/bin/bash

raspberry_pi_ssid="EMLI-TEAM-13"
logged_on_wifi=false

# Function to check if the Raspberry Pi SSID is in the list of nearby networks
check_wifi_ssid() {
   
    while [ "$logged_on_wifi" = false ]; do 
        # Scan for nearby WiFi networks
        nearby_networks=$(nmcli dev wifi list | awk '{if (NR>1) print $2}')
    
        # Check if the Raspberry Pi SSID is in the list of nearby networks
        for ssid in $nearby_networks; do
            if [ "$ssid" = "$raspberry_pi_ssid" ]; then
                nmcli dev wifi connect "$raspberry_pi_ssid" password "emliemli"
                logged_on_wifi=true
                return 0 # Raspberry Pi SSID found
            fi
        done
        logged_on_wifi=false
        echo "Wi-Fi not found"
        return 1 # Raspberry Pi SSID not found    
    done
}

# Function to synchronize time of wildlife camera with the time of the drone
sync_time(){
    timedatectl set-ntp true
}

# Function to log wifi stats
log_wifi_stats(){
    echo "Thread log_wifi_stats is running..."
    while [ "$logged_on_wifi" = true ]; do # While the drone is logged onto the wifi
        ./wifi_logging.sh
        sleep 5
    done
    echo "Thread log_wifi_stats stopped."
}

# Function to copy photos
copy_photos(){
    echo "Thread copy_photos is running..."
    while [ "$logged_on_wifi" = true ]; do # While the connection is better than e.g. 10
        ./drone_copy_photos.sh
        sleep 5
    done
    echo "Thread copy_photos stopped."
}

# Function to stop child task processes
stop_tasks() {
    echo "Stopping all child processes"
    pkill -P $$
    exit 0
}

# Trap SIGTERM and SIGINT signals and call stop_tasks function
trap 'stop_tasks' SIGINT SIGTERM

# Main script
while true; do
    if check_wifi_ssid $raspberry_pi_ssid; then
        echo "Connection between drone and $raspberry_pi_ssid established"

        sync_time # Synchronize time 
        echo "Time synchronized successfully."

        # Start tasks in the background
        log_wifi_stats & # Begin logging stats
        log_wifi_stats_pid=$!
        echo "log_wifi_stats process started with PID: $log_wifi_stats_pid"

        copy_photos & # Begin copying photos 
        copy_photos_pid=$!
        echo "copy_photos process started with PID: $copy_photos_pid"

        # Wait for both processes to complete or be terminated
        wait $log_wifi_stats_pid $copy_photos_pid

        # Reset logged_on_wifi if tasks are stopped
        logged_on_wifi=false
    else
        echo "Raspberry Pi access point not detected. Trying again."
        sleep 5
    fi
    sleep 10
done




