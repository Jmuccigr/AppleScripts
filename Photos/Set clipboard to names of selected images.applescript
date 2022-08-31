-- A short script to grab the filenames of the selected photos.
-- This function doesn't exist for all photos apparently.

tell application "Photos"
	set i to {}
	set nameList to {}
	set i to the selection
	set photoCount to the count of items of i
	if photoCount = 0 then
		display alert "No items" message "You don't appear to have any photos selected." giving up after 30
		error number -128
	else
		try
			repeat with j in i
				set n to ((filename of j) as string) & "-" & (size of j) as string
				set the end of nameList to n
			end repeat
		on error
			display alert "Oops" message "Something went wrong. Are you in a smart album?"
			error number -128
		end try
	end if
	set TIL to AppleScript's text item delimiters
	set AppleScript's text item delimiters to return
	set the clipboard to nameList as string
	set AppleScript's text item delimiters to TIL
	
	display notification (photoCount as string) & " filenames have been added to the clipboard." with title "All done!" sound name "beep"
	
end tell
