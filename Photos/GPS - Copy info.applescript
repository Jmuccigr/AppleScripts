-- This script takes GPS data from one file and transfers it to another.
-- .png files can hold GPS data, but Photos.app doesn't read that data unless it's in XMP tags,
-- so this script puts GPS data into those tags for png's.
-- Testing shows that jpg, tiff, and heic files can all handle GPS data in other tags.

-- Have to do this weird thing with the quit routine because of heic files
property ImageFiles : {}

on open dropped_files
	set ImageFiles to ImageFiles & dropped_files
end open

on quit
	tell application "Finder"
		set fileNo to the count of ImageFiles
		if fileNo = 1 then
			display alert "Too few files" message "You need at least 2 files for this to make sense."
			set ImageFiles to {}
			error number -128
		end if
		set names to {}
		repeat with i from 1 to fileNo
			set the end of names to (the name of item i of ImageFiles)
		end repeat
		set reply to (choose from list names with title "Pick a file" with prompt "Choose the file with the correct GPS data:")
		if reply as string is "false" then
			set ImageFiles to {}
			error number -128
		end if
		set reply to reply as string
		repeat with i from 1 to fileNo
			if (the name of item i of ImageFiles) as string = reply then
				set theSource to item i of ImageFiles
				set srcPath to the quoted form of the POSIX path of theSource
				set gpsdata to paragraph 1 of (do shell script "/opt/homebrew/bin/exiftool -csv -p '$gpslatitude,$gpslongitude,$gpsaltitude,gpsdatetime' " & srcPath)
				if gpsdata = "Sourcefile" then
					display alert "No GPS data" message "The source file has no GPS data."
					set gps to false
					exit repeat
				else
					set tid to AppleScript's text item delimiters
					set AppleScript's text item delimiters to ","
					set {lat, long, alt, dt} to the text items of gpsdata
					set AppleScript's text item delimiters to tid
					set lat to quoted form of lat
					set long to quoted form of long
					set alt to quoted form of alt
					set dt to quoted form of dt
					set gps to true
				end if
				exit repeat
			end if
		end repeat
		if gps then
			repeat with j from 1 to fileNo
				if j ­ i then
					set targ to item j of ImageFiles
					set ext to the name extension of targ
					set targetPath to the quoted form of the POSIX path of targ
					if ext is in {"png"} then
						do shell script ("/opt/homebrew/bin/exiftool -xmp:GPSLatitude=" & lat & " -xmp:GPSLongitude=" & long & " -xmp:GPSAltitude=" & alt & " -GPSDateTime=" & dt & " " & targetPath)
					else
						if ext is in {"jpg", "jpeg", "heic", "tiff", "tif"} then
							try
								do shell script ("/opt/homebrew/bin/exiftool -tagsfromfile " & srcPath & " -gps* -datetimeoriginal " & targetPath)
							on error errmsg number errNum
								display alert errNum message errmsg
							end try
						end if
					end if
				end if
			end repeat
		end if
	end tell
	
	set ImageFiles to {}
	continue quit
end quit
