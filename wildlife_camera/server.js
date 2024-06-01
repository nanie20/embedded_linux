const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PHOTO_DIR = path.join('/home/emli/photos'); // Update this path if necessary
const LOG_FILE = path.join('/home/emli/server_logs.log');

// Helper function to recursively get image files from nested directories
const getFilesFromDir = (dir, fileList = []) => {
    const files = fs.readdirSync(dir);
    files.forEach(file => {
        const filePath = path.join(dir, file);
        if (fs.statSync(filePath).isDirectory()) {
            getFilesFromDir(filePath, fileList);
        } else if (file.endsWith('.jpg')) {
            fileList.push(path.relative(PHOTO_DIR, filePath));
        }
    });
    return fileList;
};

// Endpoint to get a list of images
app.get('/photos/images', (req, res) => {
    try {
        const images = getFilesFromDir(PHOTO_DIR);
        res.json(images);
    } catch (err) {
        console.error('Error fetching images', err);
        res.status(500).json({ error: 'Unable to scan directory' });
    }
});

// Endpoint to get metadata for a specific image
app.get('/photos/metadata/:date/:filename', (req, res) => {
    const { date, filename } = req.params;
    const jsonFilename = filename.replace('.jpg', '.json');
    const filepath = path.join(PHOTO_DIR, date, jsonFilename);
    fs.readFile(filepath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading metadata file', err);
            return res.status(404).json({ error: 'File not found' });
        }
        res.json(JSON.parse(data));
    });
});

// Serve the images directly
app.get('/photos/:date/:filename', (req, res) => {
    const { date, filename } = req.params;
    const filepath = path.join(PHOTO_DIR, date, filename);
    res.sendFile(filepath, (err) => {
        if (err) {
            console.error('Error sending file', err);
            res.status(404).send('File not found');
        }
    });
});

// Endpoint to get the log file
app.get('/logs', (req, res) => {
    fs.readFile(LOG_FILE, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading log file', err);
            return res.status(500).send(`Unable to read log file: ${err.message}`);
        }
        res.setHeader('Content-Type', 'text/plain');
        res.send(data);
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

