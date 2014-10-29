#iPhoto-related AppleScripts:

- Add photos to album: adds the selected photos to a comma-separated list of albums. Checks that photos are selected and that albums exist. Non-existent albums are ignored with an error.
- List albums for image: displays date and time of photo and a list of albums that contain the photo. Will do multiple photos in sequence.
- Display EXIF data: gets EXIF data via shell command "exif", not "exiftools", assuming a homebrew installation in /usr/local/bin/. Shows first 20 lines and copies everything to the clipboard.