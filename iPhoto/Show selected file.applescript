-- A short script to show the first of the selected photos in the Finder
-- This function doesn't exist for all photos apparently.

tell application "iPhoto.app"
	set i to the selection
	if i = {} then
		display alert "No selection" message "There is no photo selected." giving up after 30
	else
		set j to item 1 of i
		set myHome to POSIX path of (path to home folder)
		
		set fname to do shell script "find " & myHome & "/Pictures/Fun.photoslibrary/ -name \"" & the filename of j & "\" -print"
		tell application "Finder"
			reveal POSIX file fname as alias
			activate
		end tell
	end if
end tell