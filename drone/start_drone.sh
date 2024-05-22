#!/bin/bash

stop=false

stop_tasks() {
    stop=true


    if [ ! -z "$drone_pid" ]; then
        kill $drone_pid 2>/dev/null
    fi
    exit 0
}

# Trap SIGTERM signal and call stop_tasks function
trap 'stop_tasks' SIGINT SIGTERM
#starts the drone
start_drone() {
    while ! $stop; do
        ./drone.sh &
        drone_pid=$!
        #wait $drone_pid
        sleep 5
    done
}

start_drone
