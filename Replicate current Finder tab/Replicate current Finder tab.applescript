tell application "Finder"
	if the number of windows is not greater than 0 then
		display alert "No windows" message "There are no open windows."
	else
		activate
		set theTarget to the target of the front window
		tell application "System Events" to keystroke "t" using command down
		delay 0.1 -- Seems necessary in Monterey
		set the target of the front window to theTarget
	end if
end tell