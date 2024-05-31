#!/bin/bash

# Define base directory for photo storage
base_directory="/home/emli/photos"

# MQTT settings
mqtt_broker="192.168.10.1"
mqtt_topic="/feeds/animal"
mqtt_username="emli13"
mqtt_pw="emli13"

# Command to subscribe and receive a message
subscribe_command="mosquitto_sub -h $mqtt_broker -t $mqtt_topic -C 1 -u $mqtt_username -P $mqtt_pw"

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

  local filename="${current_time}.jpg"
  local full_path="${photo_directory}/${filename}"

  # Using rpi-cam to take the photo
  rpicam-still -o "$full_path"

  # Extract EXIF data using exiftool
  local subject_distance=$(exiftool -SubjectDistance -b "$full_path")
  local exposure_time=$(exiftool -ExposureTime -b "$full_path")
  local iso=$(exiftool -ISO -b "$full_path")

  # Create the JSON metadata file
  local json_file="${photo_directory}/${filename%.jpg}.json"
  cat > "$json_file" <<EOF
{
  "File Name": "$filename",
  "Create Date": "$date_time_with_ms",
  "Create Seconds Epoch": $seconds_since_epoch,
  "Trigger": "$trigger",
  "Subject Distance": "${subject_distance:-Unknown}",
  "Exposure Time": "${exposure_time:-Unknown}",
  "ISO": "${iso:-Unknown}"
}
EOF
  echo "Photo and metadata saved: $full_path and $json_file"
}

# Function to handle motion detection
check_motion() {
  local img1=$1
  local img2=$2
  local motion_detected=$(python3 ~/MotionDetect.py "$img1" "$img2")
  if [[ "$motion_detected" == "Motion detected" ]]; then
    take_photo "Motion"
  fi
}

# Main loop to handle triggers
last_image=""
last_time_capture=$(date +%s)

while true; do
  current_time=$(date +%s)

  # Capture a photo every 5 minutes with "Time" trigger
  if (( current_time >= last_time_capture + 300 )); then
    take_photo "Time"
    last_time_capture=$current_time
  fi

  # Capture a photo every second for motion detection
  current_image=$(take_photo "Time")

  # Check for motion if there is a last image to compare
  if [[ -n "$last_image" ]]; then
    check_motion "$last_image" "$current_image"
  fi
  last_image="$current_image"

  # Check for external trigger via MQTT
  if external_message=$(timeout 1 $subscribe_command); then
    take_photo "External"
  fi

  sleep 1  # Wait for 1 second before next loop iteration
done