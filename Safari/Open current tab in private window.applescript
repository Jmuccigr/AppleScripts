-- Very boring script to open the current tab in a new private window.
-- For those times when something stupid is happening (Cloudflare).

tell application "Safari"
	set privateURL to the URL of the current tab of window 1
	
	tell application "System Events"
		click menu item "New Private Window" of menu "File" of menu bar 1 of application process "Safari"
	end tell
	
	tell window 1 to set properties of current tab to {URL:privateURL}
end tell

