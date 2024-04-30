#!/usr/bin/env bash

# Define source and destination directories
source_dir="/Users/annecathrinekirkegaard/Documents/emli/source"
destination_dir="/Users/annecathrinekirkegaard/Documents/emli/destination"

object='{"COPIED": true}' 

# Loop over each file in the source directory
for file in "$source_dir"/*.json; do 

    filename=$(basename "$file" .json) 
    statement=$(jq '.COPIED' "$file") 

    # check if a file is previously copied 
    if [ "$statement" = "true" ]; then 
        jq '.' $file 
        echo File "$(basename "$file")" is already in destination folder 

    elif [ "$statement" = null ]; then 
        # copy .json file 
        echo "Copying file: $file to $destination_dir" 
        cp "$file" "$destination_dir" 
        
        # add fields to file 
        echo "Adding field to $file" 
        jq --argjson x "$object" '. += $x' < "$file" > $source_dir/tmp.json 
        mv $source_dir/tmp.json "$file" 

        # copy .jpg file 
        echo "Copying file: $filename.jpg to $destination_dir" 
        cp "$source_dir/$filename.jpg" "$destination_dir" 
    fi
done



