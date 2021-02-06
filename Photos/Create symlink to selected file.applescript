-- A short script to create symlinks for the selected photos.
-- This function doesn't exist for all photos apparently, including those
-- in smart albums

-- Set the destinatino folder right away. Change this, if you want your photos in a different location.
set pics to (path to pictures folder) as string
set macdest to (pics & "collection:") as alias

tell application "Photos"
	set photoList to the selection
	if photoList = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		set pics to POSIX path of pics
		set dest to POSIX path of macdest
		set dirname to ""
		set destPath to ""
		repeat until dirname is not ""
			set dirname to (choose folder with prompt "Select a folder in which to save the image(s)." default location macdest)
		end repeat
		repeat with selectedPhoto in photoList
			try
				set photoProps to the properties of selectedPhoto
				set photoID to the id of photoProps
				set photoName to the filename of photoProps
			on error errMsg number errNum
				beep
				display alert "Oops" message "Something went wrong. Are you selecting a photo in a Smart Album by chance?" & return & errMsg
			end try
			
			-- Grab path to original file for image
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "/"
			set photoID to the first text item of photoID
			set AppleScript's text item delimiters to tid
			set fname to (do shell script "find " & pics & "Fun.photoslibrary/originals -name \"" & photoID & "*\" -print")
			
			-- Make symlink in collection folder
			do shell script "ln -s " & quoted form of fname & space & quoted form of (POSIX path of dirname & photoName)
		end repeat
	end if
end tell