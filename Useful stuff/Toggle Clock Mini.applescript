set appName to "Clock mini"
tell application "System Events"
	set currentApp to the name of (process 1 where frontmost is true)
	if currentApp is not appName then
		tell application "Clock mini"
			reopen
			activate
		end tell
	else
		tell application "Finder" to set visible of process appName to false
	end if
end tell