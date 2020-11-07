-- Find albums that contain the (first) selected image

tell application "Photos"
	set albumList to {}
	set selectedphoto to the selection
	-- Make sure a photo is actually selected
	if selectedphoto is {} then
		display alert "No photos selected" message "You need to select a single photo."
		return
	end if
	set selectedphoto to item 1 of selectedphoto
	-- Shared-album photos don't work
	try
		set photoID to id of selectedphoto
	on error errMsg number errNum
		display alert "Oops" message "There was a problem getting the photo ID. Did you select a photo in a shared album?" & return & return & errNum & ": " & errMsg
		error number -128
	end try
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
end tell
