#!/bin/bash

stop=false

stop_tasks() {
    stop=true
}

# Trap SIGTERM signal and call stop_tasks function
trap 'stop_tasks' SIGINT SIGTERM
#starts the drone
start_drone() {
    while ! $stop; do
        ./drone.sh
    done
}

start_drone
