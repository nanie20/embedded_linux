#!/bin/bash

# Define source and destination directories
source_dir="./source"
destination_dir="./destination"

object='{"COPIED": true}' 

# Loop over each file in the source directory
for file in "$source_dir"/*.json; do 

    filename=$(basename "$file" .json) 
    statement=$(jq '.COPIED' "$file") 

    # check if a file is previously copied 
    if [ "$statement" = "true" ] 
    then 
        jq '.' $file 
        echo File "$(basename "$file")" is already in destination folder 
    else 
        # copy .json file 
        echo "Copying file: $file to $destination_dir" 
        cp "$file" "$destination_dir" 
        
        # add fields to file 
        echo "Adding field to $file" 
        jq --argjson x "$object" --arg y "$destination_dir" '. += $x | .Destination = $y' < "$file" > "$source_dir/tmp.json" && mv "$source_dir/tmp.json" "$file"

        # copy .jpg file 
        echo "Copying file: $filename.jpg to $destination_dir" 
        cp "$source_dir/$filename.jpg" "$destination_dir" 
    fi
done



