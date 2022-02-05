-- A short script to grab the filenames of the selected photos.
-- This function doesn't exist for all photos apparently.

tell application "Photos"
	set i to {}
	set nameList to {}
	set i to the selection
	if the number of items of i = 0 then
		display alert "No items" message "You don't appear to have any photos selected." giving up after 30
		error number -128
	else
		repeat with j in i
			set n to filename of j as string
			set the end of nameList to n
		end repeat
	end if
	set TIL to AppleScript's text item delimiters
	set AppleScript's text item delimiters to return
	set the clipboard to nameList as string
	set AppleScript's text item delimiters to TIL
end tell
