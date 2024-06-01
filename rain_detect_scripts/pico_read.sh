#!/bin/bash

# MQTT broker
MQTT_BROKER="localhost"
MQTT_PORT=1883
MQTT_RAIN_TOPIC="/feeds/rain"
MQTT_COMMAND_TOPIC="/feeds/wiper"
MQTT_USERNAME="emli13"
MQTT_PASSWORD="emli13"
SERIAL_DEVICE="/dev/ttyACM0"
BAUD_RATE=115200

# serial port with raw mode to avoid any processing of incoming data.
stty -F $SERIAL_DEVICE $BAUD_RATE raw -echo

# publish data to MQTT -
# $1 - MQTT topic to publish to, $2 is the payload
publish_to_mqtt() {
  mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "$1" -u $MQTT_USERNAME -P $MQTT_PASSWORD -m "$2"
}

# handle incoming MQTT commands and forward them to the Pico.
# $1 is the received command from MQTT to be passed to the Pico via serial
handle_command() {
  echo "$1" > $SERIAL_DEVICE
}

# Subscribe to MQTT command topic and handle incoming commands
mosquitto_sub -h $MQTT_BROKER -p $MQTT_PORT -t $MQTT_COMMAND_TOPIC -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r CMD; do
  handle_command "$CMD"
done &

# Main loop to read data from the Pico and publish it to MQTT.
cat $SERIAL_DEVICE | while IFS= read -r LINE; do
  echo "Read from Pico: $LINE"  # Log the data read from the Pico for debugging.
  publish_to_mqtt $MQTT_RAIN_TOPIC "$LINE"  # Publish the data to the MQTT rain topic.
done