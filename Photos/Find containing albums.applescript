-- Find albums that contain the (first) selected image

global albumCt, allAlbums

tell application "Photos"
	set t1 to do shell script "date +%s"
	-- Set notification spacing by percentage points of total album count
	set interval to 10
	set update to false
	set albumCt to 0
	set albumList to {}
	set allAlbums to {}
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
			my albumCount()
			if albumCt > 50 then
				set update to true
				set notifyCt to (albumCt * interval / 100) as integer
			end if
			set counter to 1
			set noteCounter to 1
			display notification ("Starting!") with title "Let's go!" sound name "funk"
			--This next line works and is more elegant, but it's slower
			--set albumList to name of (albums whose id of media items contains photoID)
			repeat with theAlbum in allAlbums
				if counter = notifyCt and noteCounter is not 4 then
					display notification ("Done with " & (noteCounter * interval) & "% of the albums." & return & name of theAlbum as string) with title "Progress Update" sound name "funk"
					set noteCounter to noteCounter + 1
					set counter to 0
				end if
				if (id of the media items of theAlbum contains photoID) then
					
					copy (name of theAlbum as string) to the end of albumList
				end if
				set counter to counter + 1
			end repeat
			set t2 to do shell script "date +%s"
			set timer to "Completed in " & (t2 - t1) & " seconds."
			if albumList ­ {} then
				set tid to AppleScript's text item delimiters
				set AppleScript's text item delimiters to return
				display dialog "This photo belongs to these albums:" & return & return & albumList & return & return & timer as string
				set AppleScript's text item delimiters to tid
			else
				display alert "Sorry" message "This photo belongs to no albums." & return & return & timer
			end if
		on error errMsg
			display alert "Error" message errMsg
		end try
	end if
end tell

on albumCountIn(parentRef)
	using terms from application "Photos"
		tell parentRef
			set albumCt to albumCt + (count of albums)
			repeat with a in albums
				copy a to the end of allAlbums
			end repeat
			repeat with i in folders
				set f to contents of i
				my albumCountIn(f)
			end repeat
		end tell
	end using terms from
end albumCountIn

on albumCount()
	albumCountIn(application "Photos")
end albumCount
