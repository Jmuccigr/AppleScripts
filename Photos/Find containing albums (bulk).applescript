-- Find albums that contain the (first) selected image

global albumList, photoID, subsearch, skipEvents

tell application "Photos"
	set t1 to do shell script "date +%s"
	set subsearch to false
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
			set reply to button returned of (display dialog "Do you want to search folders, too?" buttons {"No", "Yes"} default button 2)
			set subsearch to (reply is "Yes")
			set reply to button returned of (display dialog "Do you want to skip iPhoto Events?" buttons {"No", "Yes"} default button 2)
			set skipEvents to (reply is "Yes")
			display notification ("Starting!") with title "Let's go!" sound name "funk"
			my searchIn(application "Photos")
			set t2 to do shell script "date +%s"
			set timer to "Completed in " & (t2 - t1) & " seconds."
			if albumList ­ {} then
				set tid to AppleScript's text item delimiters
				set AppleScript's text item delimiters to return
				display alert "Results" message ("This photo belongs to these albums:" & return & return & albumList & return & return & timer as string)
				set AppleScript's text item delimiters to tid
			else
				display alert "Sorry" message "This photo belongs to no albums." & return & return & timer
			end if
		on error errMsg
			display alert "Error" message errMsg
		end try
	end if
end tell

on searchIn(parentRef)
	using terms from application "Photos"
		tell parentRef
			with timeout of 300 seconds
				if name of parentRef is not "_Smart albums" then -- Need to skip what can be large smart albums
					display notification ("Now working in " & name of parentRef) with title "Update" sound name "funk"
					copy name of (albums whose id of media items contains photoID) to the end of albumList
				end if
			end timeout
			if subsearch then
				repeat with i in folders
					set n to name of i
					if (skipEvents and n = "iPhoto Events") then
					else
						set f to contents of i
						my searchIn(f)
					end if
				end repeat
			end if
		end tell
	end using terms from
end searchIn
