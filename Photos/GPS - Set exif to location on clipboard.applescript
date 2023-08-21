-- A script to take a pair of comma-separated numbers on the clipboard and set
-- the lat and long of the original file of the first selected photo to those values
tell application "Photos"
	activate
	tell application "Finder"
		set myHome to POSIX path of (path to home folder)
	end tell
	set lib to (do shell script myHome & ".local/bin/osxphotos list | grep \\# | head -n 1 | perl -pe 's/.*?(\\/.*)/\\1/'")
	if lib = "" then
		display alert "Software missing" message "osxphotos does not appear to be installed."
		error -128
	else
		set lib to the quoted form of lib
	end if
	-- This determines how close the Photos and original file GPS coords can be w/o updating
	set precision to 5
	set margin to 10 ^ (-(precision - 1))
	-- Get the selection. Right now only handling one image.
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		set photoCount to the number of items of i
		if photoCount > 10 then
			set lots to true
		else
			set lots to false
		end if
		-- See if the user wants to check for closeness
		set checkCloseness to the button returned of (display dialog "Do you want to leave alone coordinates that are already close to the desired ones?" buttons {"Yes", "No", "Cancel"} default button 1)
		repeat with counter from 1 to photoCount
			set longDiff to false
			set latDiff to false
			set j to ""
			repeat until j is not ""
				try
					set j to item counter of i
					-- First get the actual image file location
					set photoID to the id of j
					set photoName to (the filename of j) as string
				on error
					try
						set reply to button returned of (display dialog "You might be in a Smart Album. Shall I try to find the original photo?" buttons {"No", "Yes"} default button 2 cancel button 1)
						if reply = "Yes" then
							tell application "System Events" to tell process "Photos" to click menu item "Show in All Photos" of menu 1 of menu bar item "File" of menu bar 1
							-- Apparently need to wait for the app to catch up to the switch in albums
							delay 1
							set i to the selection
							set j to item 1 of i
							set photoID to the id of j
							set photoName to (the filename of j) as string
						else
							error
						end if
					on error errMsg number errNum
						if errMsg is not "Photos got an error: User canceled." then display alert errNum message "Can't get to photo:" & return & errMsg
						error number -128
					end try
				end try
			end repeat
			set j to ""
			-- Now get the original file
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "/"
			set photoID to the first text item of photoID
			set AppleScript's text item delimiters to tid
			try
				set fname to (do shell script "find " & lib & "/originals -name \"" & photoID & "*\" -print | grep \"originals\" | grep -v \".aae\" ")
			on error errMsg number errNum
				display alert errNum message "Could not find the image file for:" & return & errMsg
				error number -128
			end try
			if the (count of paragraphs of fname) > 1 then
				set reply to button returned of (display dialog "There appear multiple copies of this image." & return & return & fname as string buttons {"Cancel", "Set them all"} default button 2 with title "Oops")
				if reply = 2 then error number -128
			end if
			-- Then get the location data from the clipboard
			try
				set coords to (the clipboard as string)
				set coords to (do shell script "pbpaste | sed 's/[^\\.0-9, ]//g'")
				set coords to my replace(coords, ",", " ")
				set {lat, long} to words 1 thru 2 of coords
				lat as number
				long as number
			on error
				display alert "Oops" message "Photo " & photoName & return & "Problem getting the location from the clipboard."
				error number -128
			end try
			if lat < 0 then
				set latRef to "S"
			else
				set latRef to "N"
			end if
			if long < 0 then
				set longRef to "W"
			else
				set longRef to "E"
			end if
			set lat to my roundoff(lat, precision)
			set long to my roundoff(long, precision)
			repeat with fnameline in paragraphs of fname
				-- Get exif data for GPS if there is any
				set gpsTemp to (do shell script "/opt/homebrew/bin/exiftool -p '$gpslatitude#, $gpslongitude#, $gpslatituderef#, $gpslongituderef#' " & quoted form of fnameline)
				-- Catch files without GPS
				if gpsTemp is not "" then
					set {fileLat, fileLong, fileLatRef, fileLongRef} to words of gpsTemp
					set fileLat to my roundoff(fileLat, precision)
					set fileLong to my roundoff(fileLong, precision)
					-- If the coords are the same up to the desired precision, leave it alone unless the user said not to worry
					if checkCloseness = "No" then
						set longDiff to true
					else
						set latDiff to (my abs(fileLat - lat) > margin)
						set longDiff to (my abs(fileLong - long) > margin)
					end if
				else
					-- Just set this variable to indicate that the file needs its coords set
					set longDiff to true
				end if
				if (longDiff or latDiff) then
					set gpsCommand to "/opt/homebrew/bin/exiftool -overwrite_original -gpslatituderef=" & latRef & "  -gpslongituderef=" & longRef & " -GPSLatitude=" & lat & " -GPSLongitude=" & long & " " & quoted form of fnameline
					set theResult to (do shell script gpsCommand)
					if theResult ­ "    1 image files updated" then
						display alert "A problem?" message "Photo " & filename & return & "The exiftool command did not have the expected result for this photo:" & return & theResult as warning giving up after 30
					else
						set theResult to my do_submenu("Photos", "Image", "Location", "Revert to Original Location")
						if not lots then
							if theResult then
								display notification ("The coordinates in image " & photoName & " have been updated and Photos has reloaded them.") with title "Success!" sound name "beep"
							else
								display alert "A problem?" message "Photo " & filename & return & "Photos doesn't seem to have updated the coordinates for this photo in its database. Better check on that." as warning giving up after 30
							end if
						end if
					end if
				else
					if not lots then
						display notification ("The coordinates in image " & photoName & " are close enough to the Photos data.") with title "Already set!" sound name "funk"
					end if
				end if
			end repeat
		end repeat
		if lots then display dialog "Done processing the " & photoCount & " images."
	end if
end tell

on roundoff(value, places)
	set newValue to (round (10 ^ places * value)) / (10 ^ places)
	return newValue
end roundoff

on abs(num)
	try
		set num to num as number
		if num < 0 then set num to (num * -1)
		return num
	on error
		display alert "Not a number!" message "Can't get the absolute value of something that isn't a number" as warning giving up after 30
	end try
end abs

on do_submenu(app_name, menu_name, menu_item, submenu_item)
	try
		-- bring the target application to the front
		tell application app_name
			activate
		end tell
		tell application "System Events"
			tell process app_name
				tell menu bar 1
					tell menu bar item menu_name
						tell menu menu_name
							tell menu item menu_item
								tell menu menu_item
									click menu item submenu_item
								end tell
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
		return true
	on error error_message
		return false
	end try
end do_submenu

-- Quick search and replace with TID
on replace(origtext, ftext, rtext)
	set tid to AppleScript's text item delimiters
	set newtext to origtext
	set AppleScript's text item delimiters to ftext
	set newtext to the text items of newtext
	set AppleScript's text item delimiters to rtext
	set newtext to the text items of newtext as string
	set AppleScript's text item delimiters to tid
	return newtext
end replace
