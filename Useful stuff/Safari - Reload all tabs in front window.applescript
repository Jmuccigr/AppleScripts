tell application "Safari"
	activate
	tell (window 1)
		repeat with t from 1 to the count of every tab 
			do JavaScript "window.location.reload()" in tab t
		end repeat
	end tell
end tell
