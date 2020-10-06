-- Uses Ryan Baumann's academia.edu download script to download the file associated
-- with the current page. https://github.com/ryanfb/academia-dl

on run
	-- Get the current URL, different methods for different browsers
	set currentURL to ""
	tell application "System Events" to set browserApp to the name of (process 1 where frontmost is true)
	if browserApp = "Safari" then
		tell application "Safari" to set currentURL to ((URL of document 1) as string)
	else if browserApp = "Chromium" then
		tell application "Chromium" to set currentURL to the URL of the active tab of window 1
	else if browserApp = "Google Chrome" then
		tell application "Google Chrome" to set currentURL to the URL of the active tab of window 1
	else if browserApp = "FireFox" then
		tell application "Firefox"
			tell application "System Events"
				keystroke "l" using {command down}
				keystroke "c" using {command down}
				delay 1
				set currentURL to the clipboard
			end tell
			activate
		end tell
	else
		do shell script "afplay /System/Library/Sounds/Basso.aiff"
		display alert "Unsupported browser" as critical message "This browser is not yet supported."
		error -128
	end if
	
	-- Check for academia.edu website, even though the ruby script does this, too
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/"
	if text item 3 of currentURL does not contain "academia.edu" then
		do shell script "afplay /System/Library/Sounds/Basso.aiff"
		display alert "Not academia.edu" message "This only works on an academia.edu page." as critical
		error -128
	end if
	
	-- Make sure the output filename isn't too big
	set fname to the last text item of currentURL
	set AppleScript's text item delimiters to tid
	set URLlength to the length of fname
	if URLlength > 251 then set URLlength to 251
	set fname to (characters 1 thru URLlength of fname) as string
	
	-- Go get the file. Note that the PATH has to be set to avoid defaulting to the system ruby
	set myHome to POSIX path of (path to home folder)
	set myPath to quote & "$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:$PATH" & quote
	try
		set resp to do shell script ("export PATH=" & myPath & ";" & myHome & "Documents/github/local/academia-dl/academia-dl.rb \"" & currentURL & "\" 2>&1")
		if resp ­ "" then
			do shell script "afplay /System/Library/Sounds/Basso.aiff"
			display alert "Oops!" message resp as critical giving up after 30
		else
			display notification "File downloaded: " & fname & ".pdf" with title "Success!" sound name "default"
		end if
	on error errMsg number errNum
		display alert "Problem" message errNum & ": " & errMsg
	end try
end run