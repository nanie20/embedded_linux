#!/bin/bash

stop=false

stop_tasks() {
    stop=true
    
    if [ $drone_pid -ne 0 ]; then
        kill $drone_pid
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
        echo "drone process started with PID: $drone_pid"
        sleep 5
    done
}

start_drone
