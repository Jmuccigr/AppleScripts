-- iPhoto "Add photos to album" Script
--
-- Developed by John Muccigrosso
-- Version 0.3 28 Oct 2014

tell application "iPhoto"
	set s to the selection
	if the class of item 1 of s is not photo then
		display alert "Not a photo" message "You must select one or more photos." giving up after 60
		error number -128
	end if
	set theReply to display dialog "Enter the name(s) of the album(s) you wish to add the selected photos to. Separate them with commas:" default answer "album names" buttons {"Cancel", "OK"} default button 2
	if the button returned of theReply is not "Cancel" and theReply ­ "" then
		set theAlbums to the text returned of theReply
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ","
		set theAlbums to the text items of theAlbums
		set foundAlbums to {}
		try
			repeat with albumName in theAlbums
				-- Remove any white-space padding on the album name
				set albumName to do shell script "echo " & albumName & "| sed -e 's/^[ \\t]*//g' | sed -e 's/[ \\t]*$//g'"
				-- Check that album exists and add it to the list if it does
				if exists album albumName then
					copy albumName to the end of foundAlbums
				end if
			end repeat
			if foundAlbums = {} then
				error "Did not find any matching albums."
			else
				try
					repeat with targetAlbum in foundAlbums
						add the selection to album targetAlbum
					end repeat
					display dialog "Done!" giving up after 10
				on error
					display alert "Oops" message "Problem adding photo to album." giving up after 30
				end try
			end if
		on error errStr number errNum
			display alert errStr
		end try
	else
		error number -128
	end if
end tell