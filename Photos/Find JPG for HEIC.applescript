-- A script to favorite JPG photos in a moment when they have a corresponding HEIC file.
-- They can then be manually checked and deleted.

tell application "Photos"
	-- Manually select a moment. This can be a bit of a long list, but at least it's sorted by date
	set i to 0
	set momentList to the name of every moment
	set selectedMoment to {choose from list momentList}
	set m to (item 1 of selectedMoment)
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
	
	-- Notify of completion with different sounds depending on what happens
	set soundName to "Sosumi"
	if i = 1 then
		set i to (i & " photo was ") as string
	else
		if i = 0 then set soundName to "Basso"
		set i to (i & " photos were ") as string
	end if
	display notification (i & "identified.") with title "Moment processed!" sound name soundName
	
end tell