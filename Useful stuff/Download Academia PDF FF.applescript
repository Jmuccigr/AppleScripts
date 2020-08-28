-- Uses Ryan Baumann's academia.edu download script to download the file associated
-- with the current page. https://github.com/ryanfb/academia-dl

on run
	tell application "Firefox"
		tell application "System Events"
			keystroke "l" using {command down}
			keystroke "c" using {command down}
			delay 1
			set currentURL to the clipboard
		end tell
		activate
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "/"
		if text item 3 of currentURL does not contain "academia.edu" then
			do shell script "afplay /System/Library/Sounds/Basso.aiff"
			display alert "Not academia.edu" message "This only works on an academia.edu page." as critical
			error -128
		end if
		set fname to the last text item of currentURL
		set AppleScript's text item delimiters to tid
		set fname to (characters 1 thru 251 of fname) as string
	end tell
	set myHome to POSIX path of (path to home folder)
	set myPath to quote & "$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:$PATH" & quote
	set resp to do shell script ("export PATH=" & myPath & ";" & myHome & "Documents/github/local/academia-dl/academia-dl.rb \"" & currentURL & "\" 2>&1")
	if resp ­ "" then
		do shell script "afplay /System/Library/Sounds/Basso.aiff"
		display alert "Oops!" message resp as critical giving up after 30
	else
		display notification "File downloaded: " & fname & ".pdf" with title "Success!" sound name "default"
	end if
end run