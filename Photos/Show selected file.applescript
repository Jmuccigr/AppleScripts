-- A short script to show the first of the selected photos in the Finder
-- This function doesn't exist for all photos apparently.

tell application "Photos"
	set i to {}
	set i to the selection
	if the number of items of i > 10 then
		display alert "No items" message "You don't appear to have any photos selected." giving up after 30
		error number -128
	end if
	set j to item 1 of i
	tell application "Finder"
		set myHome to POSIX path of (path to home folder)
	end tell
	set lib to (do shell script myHome & ".local/bin/osxphotos list | grep \\# | head -n 1 | perl -pe 's/.*?(\\/.*)/\\1/'")
	if lib = "" then
		display alert "Software missing" message "osxphotos does not appear to be installed."
		error -128
	end if
	
	try
		set photoID to the id of j
	on error
		set reply to button returned of (display dialog "You might be in a Smart Album. Shall I try to find the original photo?" buttons {"No", "Yes"} default button 2 cancel button 1)
		try
			if reply = "Yes" then
				tell application "System Events" to tell process "Photos" to click menu item "Show in All Photos" of menu 1 of menu bar item "File" of menu bar 1
				-- Apparently need to wait for the app to catch up to the switch in albums
				delay 1
				set i to the selection
				set j to item 1 of i
				set photoID to the id of j
			else
				error
			end if
		on error errMsg number errNum
			if errMsg is not "Photos got an error: User canceled." then display alert errNum message "Can't get to photo:" & return & errMsg
			error number -128
		end try
	end try
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/"
	set photoID to the first text item of photoID
	set AppleScript's text item delimiters to tid
	-- Look for copies in the original folder and ignore the .aae files that track edits
	set fname to (do shell script "find " & quoted form of lib & "/originals -name \"" & photoID & "*\" -print | grep \"originals\" | grep -v \".aae\" ")
	if the (count of paragraphs of fname) > 1 then
		display alert "Oops!" message "There appear multiple copies of this image. Showing the second of them."
		set fname to paragraph 2 of fname
	else
		if the (count of paragraphs of fname) = 0 then
			display alert "Oops!" message "Can't find the image file."
			error number -128
		end if
	end if
	tell application "Finder"
		reveal POSIX file fname as alias
		activate
	end tell
end tell
