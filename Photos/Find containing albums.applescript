-- Find albums that contain the (first) selected image

tell application "Photos"
	set albumList to {}
	set selectedphoto to the selection
	selectedphoto
	-- Make sure a photo is actually selected
	if selectedphoto is {} or (count of selectedphoto) > 1 then
		display alert "Photos selection" message "You need to select a single photo."
	else
		set selectedphoto to item 1 of selectedphoto
		-- Shared-album photos don't work
		try
			set photoID to id of selectedphoto
		on error errMsg number errNum
			try
				set reply to button returned of (display dialog "You might be in a Smart Album. Shall I try to find the original photo?" buttons {"No", "Yes"} default button 2 cancel button 1)
				if reply = "Yes" then
					tell application "System Events" to tell process "Photos" to click menu item "Show in All Photos" of menu 1 of menu bar item "File" of menu bar 1
					-- Apparently need to wait for the app to catch up to the switch in albums
					delay 1
					set i to the selection
					set j to item 1 of i
				else
					error
				end if
			on error errMsg number errNum
				if errMsg is not "Photos got an error: User canceled." then display alert errNum message "Can't get to photo:" & return & errMsg
				error number -128
			end try
		end try
		try
			set photoID to the id of j
			repeat with theAlbum in the albums
				--This next line works and is more elegant, but it's slower
				--set albumList to name of (albums whose id of media items contains photoID)
				if (id of the media items of theAlbum contains photoID) then
					copy (name of theAlbum as string) to the end of albumList
				end if
			end repeat
			if albumList ­ {} then
				set tid to AppleScript's text item delimiters
				set AppleScript's text item delimiters to return
				display dialog "This photo belongs to these albums:" & return & return & albumList as string
				set AppleScript's text item delimiters to tid
			else
				display alert "Sorry" message "This photo belongs to no albums."
			end if
		end try
	end if
end tell
