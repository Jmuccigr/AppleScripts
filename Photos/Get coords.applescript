tell application "Photos"
	-- Get the selection. Right now only handling one image.
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		set j to item 1 of i
		try
			set fname to name of j
			set {lat, long} to the location of j
			lat as number
		on error
			display alert "Oops" message "Problem getting the location of " & fname & " from Photos."
			error number -128
		end try
		set coords to (lat & "," & long)
		set rep to button returned of (display dialog "The coords of the image are:" & return & coords buttons {"OK", "Copy to clipboard", "Map them"} default button 3)
		if rep = "Copy to clipboard" then
			tell application "System Events" to set the clipboard to coords as string
		else
			if rep = "Map them" then
				tell application "System Events" to open location ("http://www.google.com/maps/place/" & coords)
			end if
		end if
	end if
end tell
