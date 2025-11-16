global namelist


tell application "Photos"
	set namelist to the name of every album
	repeat with fol in folders
		my getAlbumNames(fol)
	end repeat
	set AppleScript's text item delimiters to return
	set the clipboard to namelist as string
	display alert "The clipboard has been set to the list of album names."
end tell

on getAlbumNames(f)
	global namelist
	
	using terms from application "Photos"
		if name of f does not contain "Smart albums" then -- Need to skip what can be large smart albums
			tell f
				try
					set the end of namelist to the name of every album
					repeat with fol in folders
						my getAlbumNames(fol)
					end repeat
				on error errMsg number errNum
					display alert "Error going through folders" message errMsg
					error number -128
				end try
			end tell
		end if
	end using terms from
end getAlbumNames