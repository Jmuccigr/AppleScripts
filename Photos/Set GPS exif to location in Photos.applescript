tell application "Photos"
	-- This determines how close the Photos and original file GPS coords can be w/o updating
	set precision to 5
	-- Get the selection. Right now only handling one image.
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		-- First get the actual image file location
		set j to item 1 of i
		set myHome to POSIX path of (path to home folder)
		try
			set photoID to the id of j
		on error
			beep
			display alert "Oops" message "Something went wrong. Are you selecting a photo in a Smart Album by chance?"
			error number -128
		end try
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
			display alert "Oops" message "Problem getting the location from Photos."
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
		else
			display alert "Already set!" message "The coordinates in the original image are close enough to the Photos data." as informational giving up after 30
		end if
		if theResult ­ "    1 image files updated" then
			display alert "A problem?" message "The exiftool command did not have the expected result:" & return & theResult as warning giving up after 30
		end if
		set theResult to my do_submenu("Photos", "Image", "Location", "Revert to Original Location")
		if theResult then
			display alert "Success!" message "The coordinates in the original image have been updated and Photos has reloaded them." as informational giving up after 30
		else
			display alert "A problem?" message "Photos doesn't seem to have updated the coordinates in its database. Better check on that." as warning giving up after 30
		end if
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