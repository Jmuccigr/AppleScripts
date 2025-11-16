global acount, mcount2, emptyList


tell application "Photos"
	set emptyList to {}
	set mcount2 to 0
	set acount to (count of albums)
	repeat with a in albums
		tell a
			if (count of media items) = 0 then set the end of emptyList to the name of a
		end tell
	end repeat
	
	repeat with fol in folders
		my countAlbums(fol)
	end repeat
	set ddString to "There are " & return & acount & " albums containing " & return & mcount2 & " media items."
	set AppleScript's text item delimiters to return
	if emptyList is not {} then
		set ddString to ddString & return & "The following albums are empty:" & return & emptyList
	else
		set ddString to ddString & return & "None is empty."
	end if
	display dialog ddString as string giving up after 30
	
end tell

on countAlbums(f)
	global acount, mcount2, emptyList
	
	using terms from application "Photos"
		if name of f is not "_Smart albums" then -- Need to skip what can be large smart albums
			tell f
				try
					set acount to acount + (count of albums)
					set mcount2 to mcount2 + (count of media items of every album)
					repeat with a in albums
						tell a
							if (count of media items) = 0 then set the end of emptyList to the name of a
						end tell
					end repeat
					repeat with fol in folders
						my countAlbums(fol)
					end repeat
				on error errMsg number errNum
					display alert "Error" message errMsg
					error number -128
				end try
			end tell
		end if
	end using terms from
end countAlbums
