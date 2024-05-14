#!/bin/bash

check_sqlite3_installed() {
    if command -v sqlite3 &>/dev/null; then
        echo "Sqlite is installed"
        return 0  # SQLite3 is installed
    else
        echo "Error: SQLite3 is not installed. Attempting to install..."
        # Install SQLite3 using package manager
        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y sqlite3
        elif command -v yum &>/dev/null; then
            sudo yum install -y sqlite
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y sqlite
        else
            echo "Error: Cannot install SQLite3. Package manager not found."
            return 1
        fi
        
        # Check if SQLite3 is installed after attempted installation
        if command -v sqlite3 &>/dev/null; then
            echo "SQLite3 installed successfully."
            return 0
        else
            echo "Error: Failed to install SQLite3. Cannot log WiFi info."
            return 1
        fi
    fi
}

# Call the function
check_sqlite3_installed

