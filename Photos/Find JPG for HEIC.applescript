-- A script to favorite JPG photos in an album or moment when they have a corresponding HEIC file.
-- They can then be manually checked and deleted.

tell application "Photos"
	-- Get the kind of container
	set containerchoice to (display dialog "What kind of container do you want to look at the photos in?" buttons {"Album", "Moment", "Cancel"} default button "Album")
	set i to 0
	
	-- Manually select a container. This can be a bit of a long list for moments, but at least it's sorted by date
	if button returned of containerchoice is "Album" then -- it's an album
		set albumList to the name of every album
		set selectedalbum to {choose from list my simpleSort(albumList)}
		set m to (item 1 of selectedalbum)
		if m = "" then error number -128
		set mm to item 1 of (every album whose name is (m as string))
		
		-- Look for HEIC files and then favorite any corresponding JPG. Keep a running count for the notification
		tell mm
			set imageList to the filename of (every media item whose filename ends with ".HEIC")
			repeat with img in imageList
				set fname to (do shell script "f=" & img & ";echo ${f%.*}")
				set ext to (do shell script "f=" & img & ";echo ${f##*.}")
				set jfile to fname & "." & "JPG"
				set the favorite of (every media item whose filename is jfile) to true
				set i to i + the (count of (every media item whose filename is jfile))
			end repeat
		end tell
	else -- it's a moment
		set momentList to the name of every moment
		set selectedMoment to {choose from list my simpleSort(momentList)}
		set m to (item 1 of selectedMoment)
		if m = "" then error number -128
		set mm to item 1 of (every moment whose name is (m as string))
		
		-- Look for HEIC files and then favorite any corresponding JPG. Keep a running count for the notification
		tell mm
			set imageList to the filename of (every media item whose filename ends with ".HEIC")
			repeat with img in imageList
				set fname to (do shell script "f=" & img & ";echo ${f%.*}")
				set ext to (do shell script "f=" & img & ";echo ${f##*.}")
				set jfile to fname & "." & "JPG"
				set the favorite of (every media item whose filename is jfile) to true
				set i to i + the (count of (every media item whose filename is jfile))
			end repeat
		end tell
		
	end if
	-- Notify of completion with different sounds depending on what happens
	set soundName to "Sosumi"
	if i = 1 then
		set i to (i & " photo was ") as string
	else
		if i = 0 then set soundName to "Basso"
		set i to (i & " photos were ") as string
	end if
	display notification (i & "identified.") with title "Media items processed!" sound name soundName
	
end tell

on simpleSort(oldList)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {ASCII character 10} -- always a linefeed
	set newList to do shell script "echo " & quoted form of (oldList as string) & " | sort -f"
	set newList to (paragraphs of newList)
	set AppleScript's text item delimiters to tid
	return newList
end simpleSort