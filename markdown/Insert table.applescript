-- Script to create a simple markdown pipe table

on run
	
	set tableText to ""
	set header to ""
	set sep to ""
	set success to false
	
	tell application "System Events"
		
		try
			set appName to (the name of every process whose frontmost is true) as string
		on error errMsg
			display alert "Problem" message "Could not get the name of the frontmost application."
			error number -128
		end try
	end tell
	
	-- Get the document window for later
	-- Don't know why it's necessary to avoid embedding this tell statement.
	tell application appName
		try
			activate
			set theWindow to the first item of (every window whose index is 1)
		on error errMsg
			display alert "Problem" message errMsg
			error number -128
		end try
	end tell
	
	tell application "System Events"
		
		-- Get the number of rows and columns
		repeat until success
			try
				set rowCount to text returned of (display dialog "How many rows?" default answer 3)
				set rowCount to rowCount as number
				set colCount to text returned of (display dialog "How many columns?" default answer 3)
				set colCount to colCount as number
				set success to true
			on error errStr number errNum
				if errNum = -1700 then
					display alert "Need a number" message "You have to enter a number here."
				else
					if errNum ­ -128 then display alert "Error" message errStr
					error number -128
				end if
			end try
		end repeat
		
		-- Build the table
		repeat with i from 1 to colCount
			set header to header & "|   "
			set sep to sep & "|---"
		end repeat
		set header to header & "|"
		set sep to sep & "|"
		repeat with i from 1 to rowCount
			set tableText to tableText & return & header
		end repeat
		-- This next should work, but the keystroking later is too fast and loses a return in MacDown
		--set tableText to header & return & sep & tableText & return
	end tell
	
	tell application appName
		try
			activate
			set the index of theWindow to 1
		on error errStr number errNum
			display alert errStr
		end try
	end tell
	
	tell application "System Events"
		try
			keystroke header & return & sep & tableText & return
		on error errMsg
			display alert errMsg
		end try
	end tell
	
	
end run