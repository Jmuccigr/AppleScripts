-- iPhoto "Add photos to album" Script
--
-- Developed by John Muccigrosso
-- Version 0.55 6 January 2015

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
					--Check that the album name is unique. Have to handle this at some point.
					if the (count of (albums whose name is albumName)) = 1 then
						copy albumName to the end of foundAlbums
					else
						display alert "Multiple Albums" message "There is more than one album with the name \"" & albumName & "\". I can't handle that, so this album will be skipped."
					end if
				else
					display alert "No such album" message "There is no album called \"" & albumName & "\"."
				end if
			end repeat
			if foundAlbums = {} then
				-- Display an alert only if there's more than one album or you'll get two alerts in a row for no good reason
				if the number of items of theAlbums > 1 then
					error "Did not find any matching albums."
				end if
			else
				try
					repeat with targetAlbum in foundAlbums
						add the selection to album targetAlbum
					end repeat
					display dialog "Done!" buttons {"OK"} default button 1 giving up after 10
				on error
					display alert "Oops" message "Problem adding photo to album \"" & targetAlbum & "\"." giving up after 30
				end try
			end if
		on error errStr number errNum
			display alert errStr
		end try
	else
		error number -128
	end if
end tell