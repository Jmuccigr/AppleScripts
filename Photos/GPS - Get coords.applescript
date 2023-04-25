tell application "Photos"
	set fname to ""
	set j to ""
	-- Get the selection. Right now only handling one image.
	--activate
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		repeat until j is not ""
			try
				set j to item 1 of i
				set fname to name of j
			on error
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
		end repeat
		try
			set {lat, long} to the location of j
			lat as number
		on error errMsg
			display alert "Oops" message "Problem getting the location of the selection from Photos."
			error number -128
		end try
		
		set coords to (lat & "," & long)
		set rep to button returned of (display dialog "The geographical coordinates of the image are:" & return & coords buttons {"OK", "Copy to clipboard", "Map them"} default button 3 cancel button 1)
		if rep = "Copy to clipboard" then
			tell application "System Events" to set the clipboard to coords as string
		else
			if rep = "Map them" then
				tell application "System Events" to open location ("http://www.google.com/maps/place/" & coords)
			end if
		end if
	end if
end tell
