global imageList

tell application "Photos"
	activate
	set imageList to {}
	repeat with a in albums
		my getAlbumImages(a, "/")
	end repeat
	repeat with fol in folders
		my getFolderImages(fol, "")
	end repeat
	set AppleScript's text item delimiters to return
	set the clipboard to imageList as string
	display alert "The clipboard has been set to the list of image names." giving up after 30
end tell

on getFolderImages(f, folderPath)
	global imageList
	
	using terms from application "Photos"
		if (name of f does not contain "Smart albums") and (the name of f does not end with "sm") then -- Need to skip what can be large smart albums
			tell f
				try
					set folderPath to folderPath & "/Ä" & the name of f & "/"
					display notification ("Working on folder " & folderPath) with title "Folder update" sound name "beep"
					repeat with a in albums
						my getAlbumImages(a, folderPath)
					end repeat
					repeat with fol in folders
						my getImageNames(fol, folderPath)
					end repeat
				on error errMsg number errNum
					display alert "Error going through folders" message errMsg
					set AppleScript's text item delimiters to return
					set the clipboard to imageList as string
					error number -128
				end try
			end tell
		end if
	end using terms from
end getFolderImages

on getAlbumImages(a, folderPath)
	global imageList
	
	using terms from application "Photos"
		set imagePath to (folderPath & name of a as string) & "/"
		--		display dialog imagePath
		tell a
			-- Quick check for really big, likely smart albums
			if (count of media items) < 1000 then
				repeat with p in media items
					set d to (date of p as string)
					set tid to AppleScript's text item delimiters
					set AppleScript's text item delimiters to "-"
					set imagedate to words 4 thru 2 of d as string
					set AppleScript's text item delimiters to tid
					set the end of imageList to (imagePath & the filename of p as string) & ":" & imagedate
					--display dialog imageList as string
				end repeat
			end if
		end tell
	end using terms from
end getAlbumImages