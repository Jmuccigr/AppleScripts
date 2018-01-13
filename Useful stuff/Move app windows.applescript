-- Script to move the windows of commonly running apps
-- when there's more than one desktop

-- First set some tracking variables
set mailDone to false
set messagesDone to false
set messageWbounds to {}
set mailWbounds to {}

-- Set a loop control so this doesn't run forever
-- Set it to the max value if there isn't >1 desktops
tell application "System Events"
	if (count every desktop) > 1 then
		set i to 0
		-- Get the size of the combined screens
		tell application "Finder"
			set screensize to bounds of window of desktop
		end tell
		if screensize = {0, 0, 1600, 1800} then
			set mailWbounds to {81, 923, 1521, 1800}
			set messageWbounds to {789, 923, 1519, 1799}
		else
			set mailWbounds to {174, 922, 1450, 1696}
			set messageWbounds to {723, 922, 1453, 1696}
		end if
	else
		set i to 5
	end if
	
	-- Now loop through the apps whose windows should be moved.
	-- Stop when the apps have all been moved or the loop has run enough times
	repeat until i = 5 or (mailDone and messagesDone)
		set theApps to the name of every process
		-- if "Mail" is in theApps and not mailDone then
		if "Mail" is in theApps and not mailDone then
			tell application "Mail"
				set the bounds of the first window to mailWbounds
				set mailDone to true
			end tell
		end if
		if "Messages" is in theApps and not messagesDone then
			tell application "Messages"
				set the bounds of the first window to messageWbounds
				set messagesDone to true
			end tell
		end if
		set i to i + 1
	end repeat
end tell