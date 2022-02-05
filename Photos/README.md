# Photos-related AppleScripts:

- **Copy GPS info**: copies GPS data from one file to another where the second has none.
- **Create symlink to selected file**: what it sounds like. You'll be prompted for a location to save the symlinks in.
- **Export first selected photo**: what it sounds like.
- **Find containing albums**: finds albums that contain the first selected photo. Smart Albums aren't included.
- **Find JPG for HEIC**: checks to see if there are similarly named JPG files for HEIC files in a moment and favorites them. User should then manually check and delete the JPGs if they want. You can select where to look.
- **Get coords**: if the first selected image has coordinates, this script will access them and let you copy or map them in Google maps.
- **Set clipboard to names of selected images**: what it sounds like
- **Set GPS exif to location in Photos**: Photos doesn't write location data back to the photo, but just saves them in its internal database. This script reads the internal location, compares it to the file's actual exif data and overwrites the latter with the former, provided they're at least a little different. Finally it tells Photos to "reload" the location data from the file. This last step shouldn't change anything in the Photos database, but it at least makes Photos realize it's synced with the file.
- **Set GPS exif to location in Photos**: Set the GPS data in the original file to the one set in Photos. Useful for correcting or adding GPS data.
- **Show selected file**: reveals the original file in the Finder.
