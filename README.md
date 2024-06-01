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

The `lib` folder holds the libraries for the local website.

The `public` folder holds two svg files that come with the Node.js framework.
