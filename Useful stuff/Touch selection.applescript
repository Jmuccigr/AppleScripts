on run
	tell application "Finder"
		try
			set filename to selection
			repeat with i in filename
				do shell script "touch " & quoted form of POSIX path of (i as text)
			end repeat
		on error errMsg
			display dialog "Oops, something went wrong:" & return & return & errMsg
		end try
	end tell
end run