# Image Processor

This is a simple docker container which uses `inotifywait` to monitor a folder for new files.
Once it detects that a new file got created (dropped into the folder), it checks if it is a `JPEG` image.
If so, it renames it based on the Date/Time in the EXIF data.
Afterwards it compresses it to save space and moves it into a new folder.

I use this tool to process images automatically uploaded by my camera. They usually are named `IMG_20240503_105434.jpeg` or `P1610951.JPG` and not compresed at all.

Files which are not detected as `JPEG` (eg. movies made by the camera) get directly moved to the new folder without further processing.

## Usage:
In docker compose:
```docker
services:
  image-monitor:
    build:
      context: monitor-and-modify-files
      dockerfile: Dockerfile
    container_name: image-monitor
    volumes:
      - ./uploaded:/uploaded
      - /processed:/processed
    restart: unless-stopped
```

The files must be dropped into the `uploaded` folder. The tool will move them to the `processed` folder.
