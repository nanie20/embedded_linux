#!/bin/bash

# Define base directory for photo storage
base_directory="/home/emli/photos"

# MQTT setup
MQTT_SERVER="localhost"
MQTT_PORT="1883"
MQTT_TOPIC_ANIMAL="/feeds/animal"
mqtt_username="emli13"
mqtt_pw="emli13"

# Flag to control the script execution
running=true

# PIDs for background processes
time_photos_pid=0
motion_photos_pid=0
mqtt_animal_pid=0

# Function to handle cleanup on exit
cleanup() {
  echo "Cleaning up and exiting..."
  running=false

  # Kill background processes
  if [ $time_photos_pid -ne 0 ]; then
    kill $time_photos_pid
  fi
  if [ $motion_photos_pid -ne 0 ]; then
    kill $motion_photos_pid
  fi
  if [ $mqtt_animal_pid -ne 0 ]; then
    kill $mqtt_animal_pid
  fi

  # Ensure Python script terminates
  pkill -f motion_detect.py
}

# Trap SIGINT (Ctrl+C) and call cleanup
trap cleanup SIGINT

# Function to take a photo and create metadata
take_photo() {
  local trigger=$1
  local current_date=$(date "+%Y-%m-%d")
  local current_time=$(date "+%H%M%S_%3N")
  local milliseconds=$(date "+%3N")
  local date_time_with_ms=$(date "+%Y-%m-%d %H:%M:%S.$milliseconds+02:00")
  local seconds_since_epoch=$(date +%s.%N)
  local photo_directory="${base_directory}/${current_date}"

  mkdir -p "$photo_directory"

  local photo_filename="${current_time}.jpg"
  local json_filename="${current_time}.json"
  local photo_path="${photo_directory}/${photo_filename}"
  local json_path="${photo_directory}/${json_filename}"

  # Capture photo using rpicam-still
  if ! rpicam-still -t 0.01 -o "$photo_path"; then
    echo "Error: Failed to capture photo with rpicam-still"
    return
  fi

  # Extract EXIF data using exiftool
  local exif_data
  if ! exif_data=$(exiftool "$photo_path"); then
    echo "Error: Failed to extract EXIF data from $photo_path" >> /home/emli/photos/missing_exif.log
    return
  fi

  # Parse EXIF data
  local subject_distance=$(echo "$exif_data" | grep "Subject Distance" | awk -F': ' '{print $2}' | xargs)
  local exposure_time=$(echo "$exif_data" | grep "Exposure Time" | awk -F': ' '{print $2}' | xargs)
  local iso=$(echo "$exif_data" | grep "ISO" | awk -F': ' '{print $2}' | xargs)

  # Set default values if EXIF data is missing
  subject_distance=${subject_distance:-"N/A"}
  exposure_time=${exposure_time:-"N/A"}
  iso=${iso:-"N/A"}

  # Create JSON metadata
  cat <<EOF > "$json_path"
{
  "File Name": "$photo_filename",
  "Create Date": "$date_time_with_ms",
  "Create Seconds Epoch": $seconds_since_epoch,
  "Trigger": "$trigger",
  "Subject Distance": "${subject_distance}m",
  "Exposure Time": "$exposure_time",
  "ISO": $iso
}
EOF

  # Log if any EXIF data was missing
  if [ "$subject_distance" = "N/A" ] || [ "$exposure_time" = "N/A" ] || [ "$iso" = "N/A" ]; then
    echo "Warning: Missing EXIF data for $photo_path" >> /home/emli/photos/missing_exif.log
    echo "Subject Distance: $subject_distance" >> /home/emli/photos/missing_exif.log
    echo "Exposure Time: $exposure_time" >> /home/emli/photos/missing_exif.log
    echo "ISO: $iso" >> /home/emli/photos/missing_exif.log
  fi
}

# Function to handle animal detection JSON message
#on_animal_message() {
#  local message="$1"
#  echo "Received animal detection data: $message"

  # Extract detection status from JSON (assuming it has a field "animal_detected")
#  local animal_detected=$(echo $message | jq '.animal_detected')

  # Check if animal is detected
#  if [ "$animal_detected" -eq 1 ]; then
#    echo "Animal detected, taking photo..."
#    take_photo "External"
#  else
    echo "No animal detected, no action."
#  fi
#}

on_animal_message() {
  local message="$1"
  echo "Received animal detection data: $message"

  # Always take a photo when a message is received
  echo "Taking photo due to received message..."
  take_photo "External"
}


# Function to capture a photo every 5 minutes with Trigger set to Time
capture_time_photos() {
  while $running; do
    take_photo "Time"
    sleep 300
  done
}

# Function to capture photos approximately every second and check for motion
capture_motion_photos() {
  local previous_photo=""
  while $running; do
    take_photo "Time"
    current_photo=$(ls -t ${base_directory}/*/*.jpg | head -n 1)

    if [ -n "$previous_photo" ]; then
      # Compare current and previous photos to detect motion
      if python3 /home/emli/motion_detect.py "$previous_photo" "$current_photo"; then
        take_photo "Motion"
      fi
    fi

    previous_photo="$current_photo"
    sleep 1
  done
}

# Start capturing photos every 5 minutes
capture_time_photos &
time_photos_pid=$!

# Start capturing photos approximately every second and check for motion
capture_motion_photos &
motion_photos_pid=$!

# Subscribe to the animal detection topic and handle messages
mosquitto_sub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC_ANIMAL -u $mqtt_username -P $mqtt_pw | while read MSG; do
  if ! $running; then
    break
  fi
  echo "New Animal Detection Message Received"
  on_animal_message "$MSG"
done &
mqtt_animal_pid=$!

# Wait for background processes to finish
wait