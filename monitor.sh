#!/bin/bash

echo "Starting to monitor the upload folder..."

inotifywait -m -r -e create --format '%w%f' ./uploaded | while read -r file; do
    if [ -d "$file" ] ; then
        echo "New folder detected: '$file'"
        # Nothing to do
    else
        FILE_EXTENSION="${file##*.}"
        echo "New file detected: '$file' (File extension: $FILE_EXTENSION)"

        # Check for completed write
        SIZE_BEFORE=`stat -c %s "$file"`
        while [[ true ]]; do
            sleep 1
            SIZE_NOW=`stat -c %s "$file"`            
            if [[ $SIZE_NOW -ne $SIZE_BEFORE ]]; then
                echo "File still growing ($SIZE_BEFORE -> $SIZE_NOW bytes)"
                SIZE_BEFORE=$SIZE_NOW
                continue
            fi
            
            if [[ $SIZE_NOW -eq 0 ]]; then
                echo "File is empty!"
                break
            fi
            
            echo "file seems to got written completely"
            echo "Waiting another 5s to be sure..."
            sleep 5
            
            # Move it outside of the watched folder
            mv "$file" ./processed/
            BASENAME=`basename "$file"`
            echo "Moved file from '$file' to './processed/$BASENAME'" 
            file=./processed/$BASENAME
            
            # Process the file
            FILE_TYPE=`file -b "$file" | awk '{print $1}'`
            echo "file type: $FILE_TYPE"
            
            if [[ "$FILE_TYPE" = "JPEG" ]]; then
                echo "Changing File Extension to '${file%.$FILE_EXTENSION}.jpeg'"
                mv -- "$file" "${file%.$FILE_EXTENSION}.jpg" 2> /dev/null            
                file="${file%.$FILE_EXTENSION}.jpg"
                
                echo "Compressing '$file'"
                jpegoptim -m90 "$file"
                
                echo "Renaming '$file'"
                exiftool '-FileName<${CreateDate}.jpg' -d '%Y%m%d_%H%M%S%%-c' -ext jpg "$file"
            else # Its not a JPEG 
                echo "Not processing file '$file', its not a JPEG!"
            fi
            
            echo ""
            echo "----------------------------------"
            break
        done
    fi
done
