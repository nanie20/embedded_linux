#!/bin/bash

# MQTT broker
MQTT_BROKER="localhost"
MQTT_PORT=1883
MQTT_RAIN_TOPIC="/feeds/rain"
MQTT_COMMAND_TOPIC="/feeds/wiper"
MQTT_USERNAME="emli13"
MQTT_PASSWORD="emli13"

#  wiper command via MQTT.
send_wiper_command() {
  mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t $MQTT_COMMAND_TOPIC -u $MQTT_USERNAME -P $MQTT_PASSWORD -m "{\"wiper_angle\": $1}"
}

# Subscribe to the MQTT rain topic and process messages.
mosquitto_sub -h $MQTT_BROKER -p $MQTT_PORT -t $MQTT_RAIN_TOPIC -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r MSG; do
  echo "Received message: $MSG"  # debug hell
  # extract the rain_detect value.
  RAIN_DETECT=$(echo $MSG | jq '.rain_detect')
  if [[ "$RAIN_DETECT" == "1" ]]; then  # check if rain is detected.
    # Send wiper commands in sequence 0-90-0.
    send_wiper_command 0
    sleep 1  # Delay between commands to allow servo movement.
    send_wiper_command 180
    sleep 1
    send_wiper_command 0
  fi
done