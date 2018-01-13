-- Script to expand Safari's front window to fill the screen
-- Assumes that with two monitors, it should fill the external screen, which is above the internal.
-- A bit ugly

-- Hardwired, sadly
set intWidth to 1440
set intHeight to 900

set safariBounds to {0, 0, 0, 0}

-- Set the width to the max value if there are >1 desktops
tell application "System Events"
	if (count every desktop) > 1 then
		if (count every desktop) > 2 then
			display alert "Too many monitors" message "I can only handle 2 monitors and you have more than that. Sorry"
			error number -128
		end if
		tell application "Finder"
			set monitors to the bounds of window of desktop
		end tell
		set item 3 of safariBounds to item 3 of monitors
		set item 4 of safariBounds to ((item 4 of monitors) - intHeight)
	else
		set item 3 of safariBounds to intWidth
		set item 4 of safariBounds to intHeight
	end if
	tell application "Safari"
		set the bounds of the first window to safariBounds
	end tell
	
end tell
