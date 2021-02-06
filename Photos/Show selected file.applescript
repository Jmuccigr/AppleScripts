-- A short script to show the first of the selected photos in the Finder
-- This function doesn't exist for all photos apparently.

tell application "Photos"
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		set j to item 1 of i
		set myHome to POSIX path of (path to home folder)
		
		--		set fname to do shell script "find " & myHome & "Pictures/ -name \"" & the filename of j & "\" -print"
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
		tell application "Finder"
			reveal POSIX file fname as alias
			activate
		end tell
	end if
end tell