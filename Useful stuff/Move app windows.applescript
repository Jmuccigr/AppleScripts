-- Script to move the windows of commonly running apps
-- when there's more than one desktop

-- First set some tracking variables
set mailDone to false
set messagesDone to false

-- Set a loop control so this doesn't run forever
-- Set it to the max value if there isn't >1 desktops
tell application "System Events"
	if (count every desktop) > 1 then
		set i to 0
	else
		set i to 5
	end if
	
	-- Now loop through the apps whose windows should be moved.
	-- Stop when the apps have all been moved or the loop has run enough times
	repeat until i = 5 or (mailDone and messagesDone)
		set theApps to the name of every process
		if "Mail" is in theApps and not mailDone then
			tell application "Mail"
				set the bounds of the first window to {174, 922, 1450, 1696}
				set mailDone to true
			end tell
		end if
		if "Messages" is in theApps and not messagesDone then
			tell application "Messages"
				set the bounds of the first window to {723, 922, 1453, 1696}
				set messagesDone to true
			end tell
		end if
		set i to i + 1
	end repeat
end tell