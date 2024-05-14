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
      nearby_networks=$(nmcli dev wifi list | awk '{if (NR>1) print $2}')
  
      # Check if the Raspberry Pi SSID is in the list of nearby networks
      for ssid in $nearby_networks; do
         if [ "$ssid" = "$raspberry_pi_ssid" ]; then
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

# function to log wifi stats
log_wifi_stats(){
   echo "Thread log_wifi_stats is running..."
   while [ "$logged_on_wifi" = true ]; do # WHILE the drone is logged onto the wifi
       ./wifi_logging.sh
       sleep 5
   done
   echo "Thread log_wifi_stats stopped."
}


# function to copy photos
copy_photos(){
   echo "Thread copy_photos is running..."
   while [ "$logged_on_wifi" = true ]; do # WHILE the connection is better than e.g. 10
       ./drone_copy_photos.sh
       sleep 5
   done
   echo "Thread copy_photos stopped."
}


# Function to stop child task processes
stop_tasks() {
  echo "Stopping copy_photos..."
  if [ $copy_photos_pid -ne 0 ]; then
    kill $copy_photos_pid
  fi

  echo "Stopping log_wifi_stats..."
  if [ $log_wifi_stats_pid -ne 0 ]; then
    kill $log_wifi_stats_pid
  fi
}

# Trap SIGTERM signal and call stop_tasks function
trap 'stop_tasks' SIGINT SIGTERM



# Main script
if check_wifi_ssid $raspberry_pi_ssid; then
   echo "Connection between drone and $raspberry_pi_ssid established" 

   sync_time # syncronize time 
   echo "Time synchronized successfully."

   # Start tasks in the background
   #log_wifi_stats & # begin logging stats
   #log_wifi_stats_pid=$!
   #echo "log_wifi_stats process started with PID: $log_wifi_stats_pid"


   copy_photos & # begin copying photos 
   copy_photos_pid=$!
   echo "copy_photos process started with PID: $copy_photos_pid"

else
   echo "Raspberry Pi access point not detected. Trying again."
   sleep 5
fi

wait



