-- Script to open the folder containing the first photo of a selection
tell application "iPhoto"
	try
		-- get selection
		set these_items to the selection
		-- check for single album selected
		if the class of item 1 of these_items is album then error "You have selected an album."
		if these_items = {} then error "You have not selected any photos."
		set thePhoto to item 1 of these_items
		set t to original path of thePhoto
		set f to POSIX file t as alias
		tell application "Finder"
			select f
			activate
		end tell
	on error errMsg
		display alert "Error" message errMsg
		return -1
	end try
end tell
