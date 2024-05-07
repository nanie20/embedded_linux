#!/bin/bash

raspberry_pi_ssid="EMLI-TEAM-13"
logged_on_wifi=false

# wifi stats
link_quality=0
signal_level=0 

# Function to check if the Raspberry Pi SSID is in the list of nearby networks
check_wifi_ssid() {

   while [ "$logged_on_wifi" = false ]; do 
      # scan for nearby WiFi networks
      nearby_networks=$(nmcli dev wifi list | grep "SSID:" | awk -F'"' '{print $2}')
  
      # Check if the Raspberry Pi SSID is in the list of nearby networks
      for ssid in $nearby_networks; do
         if [ "$ssid" = "$raspberry_pi_ssid" ]; then
            logged_on_wifi=true
            return 0 # Raspberry Pi SSID found
         fi
      done
      echo "wifi not found"
      return 1 # Raspberry Pi SSID not found    
   done

}


# Function to synchronize time of wildlife camera with the time of the drone
sync_time(){
   timedatectl set-ntp true
}

# function to log wifi stats
log_wifi_stats(){
   echo "Thread log_wifi_stats is running..."
   while [ "$logged_on_wifi" = true ]; do # WHILE the drone is logged onto the wifi
       echo "run logging stats script"
       ./wifi_logging.sh
   done
   echo "Thread log_wifi_stats stopped."
}


# function to copy photos
copy_photos(){
   echo "Thread copy_photos is running..."
   while [ "$logged_on_wifi" = true ]; do # WHILE the connection is better than e.g. 10
       echo "run copying photo script"
       ./drone_copy_photos.sh
   done
   echo "Thread copy_photos stopped."
}


# Main script
if check_wifi_ssid; then
   echo "Raspberry Pi access point detected"
   echo "Connection bewtween drone and $raspberry_pi_ssid established" 

   sync_time # syncronize time 
   echo "Time synchronized successfully."
  
   # Start threads in the background
   log_wifi_stats & # begin logging stats
   copy_photos & # begin copying photos 
   echo "Threads started"


else
   echo "Raspberry Pi access point not detected. Trying again."
fi





