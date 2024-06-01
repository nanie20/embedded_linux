# The structure of the repository
The `main` branch consists of all the files and folders from all the other branches. The repository has seven branches named:
- Cloud
- Node_server
- Website
- drone
- rain_detect
- raspberrypi

## The Cloud branch

The Cloud branch consists of the folders: `cloud` and `json`. 

The `cloud` folder holds the following files:
- annotate_server.py
- cloud.py

The `json` folder holds the following files:
- JSON files (metadata for the images)

## The Node_server branch

The Node_server branch consist of the folder: `wildlife_camera`.

The `wildlife_camera` folder holds the following files:
- package-lock.json
- package.json
- server.js

It also holds a folder called `node_modules` which contains all the modules for the node server.

## The Website branch

The Website branch consists of the folders: `app`, `lib`, and `public`.
It also consists of the files: next.config.mjs, package-lock.json, package.json, postcss.config.mjs, tailwind.config.ts, and tsconfig.json.

The `app` folder holds the following folders and files:
- api (folder)
- logs (folder)
- favicon.ico
- globals.css
- layout.tsx
- page.tsx

It contains the logic of the local website.

## The drone branch

The drone branch consists of a folder called `drone` which holds the following folder and files:
- destination (folder)
- LogWifi.db
- drone.sh
- drone_copy_photos.sh
- install_sqlite.sh
- start_drone.sh
- table.sql
- wifi_logging.sh
  
The `destination` folder consists of the photos and JSON files received by the wildlife camera.

The `lib` folder holds the libraries for the local website.

The `public` folder holds two svg files that come with the Node.js framework.

## The rain_detect branch

The rain_detect branch consists of a folder called `images` and `rain_detect_scripts`.

The `rain_detect_scripts` folder contains the following files:
- pico_read.sh
- wiper_pub.sh

These script contains the logic for the MQTT broker and makes the rain detector wipe when rain is detected.

## The raspberrypi branch

The raspberrypi branch consists of a folder called `animal`, which contains the following folder and file:
- esp8266_count_mqtt_modified (folder)
- take_photo.sh

The script takes photos which are saved in subdirectories.
