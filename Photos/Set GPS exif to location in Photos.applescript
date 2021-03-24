tell application "Photos"
	activate
	set myHome to POSIX path of (path to home folder)
	-- This determines how close the Photos and original file GPS coords can be w/o updating
	set precision to 5
	-- Get the selection. Right now only handling one image.
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		repeat with counter from 1 to the number of items of i
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
			set fname to (do shell script "find " & myHome & "Pictures/Fun.photoslibrary/originals -name \"" & photoID & "*\" -print")
			if the (count of paragraphs of fname) > 1 then
				display alert "Oops!" message "There appear multiple copies of this image."
				error number -128
			end if
			
			-- Then get the location data from the Photos version
			try
				set {lat, long} to the location of item 1 of i
				lat as number
			on error
				display alert "Oops" message "Photo " & photoName & return & "Problem getting the location from Photos."
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
			-- Get exif data for GPS if there is any
			set gpsTemp to (do shell script "/usr/local/bin/exiftool -p '$gpslatitude#, $gpslongitude#, $gpslatituderef#, $gpslongituderef#' " & fname)
			-- Catch files without GPS
			if gpsTemp is not "" then
				set {fileLat, fileLong, fileLatRef, fileLongRef} to words of gpsTemp
				set fileLat to my roundoff(fileLat, precision)
				set fileLong to my roundoff(fileLong, precision)
				-- If the coords are the same up to the desired precision, leave it alone
				set latDiff to (precision * (fileLat - lat) > 10 ^ (-(precision - 1)))
				set longDiff to (precision * (fileLong - long) > 10 ^ (-(precision - 1)))
			else
				-- Just set this variable to indicate that the file needs its coords set
				set longDiff to true
			end if
			if (longDiff or latDiff) then
				set gpsCommand to "/usr/local/bin/exiftool -overwrite_original -gpslatituderef=" & latRef & "  -gpslongituderef=" & longRef & " -GPSLatitude=" & lat & " -GPSLongitude=" & long & " " & fname
				set theResult to (do shell script gpsCommand)
				if theResult ­ "    1 image files updated" then
					display alert "A problem?" message "Photo " & filename & return & "The exiftool command did not have the expected result for this photo:" & return & theResult as warning giving up after 30
				else
					set theResult to my do_submenu("Photos", "Image", "Location", "Revert to Original Location")
					if theResult then
						display notification ("The coordinates in image " & photoName & " have been updated and Photos has reloaded them.") with title "Success!" sound name "beep"
					else
						display alert "A problem?" message "Photo " & filename & return & "Photos doesn't seem to have updated the coordinates for this photo in its database. Better check on that." as warning giving up after 30
					end if
				end if
			else
				display alert "Already set!" message "Photo " & photoName & return & "The coordinates in the original image are close enough to the Photos data." as informational giving up after 30
			end if
		end repeat
	end if
end tell

on roundoff(value, places)
	set newValue to (round (10 ^ places * value)) / (10 ^ places)
	return newValue
end roundoff

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