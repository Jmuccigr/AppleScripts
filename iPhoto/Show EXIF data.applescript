tell application "iPhoto"
	set p to the selection
	repeat with i in p
		if the class of i is photo then
			beep
			try
				set iPath to the quoted form of (the image path of i as string)
				set theResult to do shell script ("/opt/homebrew/bin/exif " & iPath & " | grep -v EXIF | grep -v \"+-\" | grep -v Value")
				set the clipboard to theResult
				set theResult to paragraphs 1 thru 15 of theResult
				set tid to AppleScript's text item delimiters
				set AppleScript's text item delimiters to return
				display dialog "Everything has been copied to the clipboard:" & return & return & theResult as string
				set AppleScript's text item delimiters to tid
			on error errorMessage number errNum
				if errNum = -128 then
					error number -128
				else
					display alert "Oops!" message errorMessage giving up after 60
				end if
			end try
		else
			display alert "No selection" message "You must select at least one image."
		end if
	end repeat
end tell