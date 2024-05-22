#!/bin/bash

# Define SSH credentials and directories
USER="emli"
HOST="192.168.10.1"
PASSWORD=""
SOURCE_BASE_DIR="/home/emli/photos"
DESTINATION_DIR="./destination"

object='{"COPIED": true}'

# Function to process subdirectories
process_subdirectories() {
    subdirs=$(sshpass -p "$PASSWORD" ssh $USER@$HOST "ls -d $SOURCE_BASE_DIR/*/")

    for subdir in $subdirs; do
        # Remove the trailing slash from subdir
        subdir=$(echo $subdir | sed 's:/*$::')

        # Loop over each JSON file in the current subdirectory
        json_files=$(sshpass -p "$PASSWORD" ssh $USER@$HOST "ls $subdir/*.json")
        for file in $json_files; do
            filename=$(basename "$file" .json)
            statement=$(sshpass -p "$PASSWORD" ssh $USER@$HOST "jq '.COPIED' \"$file\"")
            echo $filename

            # Check if the file is previously copied
            if [ "$statement" = "true" ]; then
                echo "File $filename.json is already in destination folder"
            else
                # Add fields to the JSON file
                echo "Adding field to $filename.json"
                sshpass -p "$PASSWORD" ssh $USER@$HOST "jq --argjson x '$object' --arg y '$DESTINATION_DIR' '. += \$x | .Destination = \$y' < \"$file\" > \"$subdir/tmp.json\" && mv \"$subdir/tmp.json\" \"$file\""

                # Copy the updated JSON file back to the local destination directory
                #sshpass -p "$PASSWORD" rsync -avz $USER@$HOST:"$file" "$DESTINATION_DIR"

                # Synchronize files from the current subdirectory to the destination directory
                sshpass -p "$PASSWORD" rsync -avz --progress $USER@$HOST:"$subdir/$filename.*" "$DESTINATION_DIR"
                echo "Files copied successfully from $subdir to $DESTINATION_DIR"
            fi
        done
    done
}

# Main loop to keep checking for new subdirectories
while true; do
    process_subdirectories
    sleep 10  # Check for new subdirectories every 60 seconds
done
