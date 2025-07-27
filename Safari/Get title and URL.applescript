tell application "Safari"
	tell window 1
		tell the current tab
			set the clipboard to the name & space & the URL
		end tell
	end tell
end tell