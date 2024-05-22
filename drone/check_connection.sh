#!/bin/bash

check_connection() {

        # Check the current connection status
        current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        
        if [ "$current_ssid" != "$raspberry_pi_ssid" ]; then
            echo "Lost connection to $raspberry_pi_ssid"
            logged_on_wifi=false
            return 1
        fi

        sleep 5  # Check every 5 seconds
}

check_connection

check_connection(){
   echo "Thread check_connection is running..."
   while [ "$logged_on_wifi" = true ]; do # WHILE the connection is better than e.g. 10
       ./check_connection.sh
       sleep 5
   done
   echo "Thread check_connection stopped."
}
