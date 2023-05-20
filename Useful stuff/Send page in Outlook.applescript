tell application "Safari"
	activate
	set theURL to URL of current tab of window 1
	set theTitle to name of current tab of window 1
	set theText to ""
	set theText to (do JavaScript "window.getSelection().toString();" in current tab of window 1)
	if theText is not "" then
		set theText to theURL & "<br><br>" & theText & "<br><br>"
	else
		set theText to theURL
	end if
end tell

tell application "Microsoft Outlook"
	activate
	set newmail to make new outgoing message with properties {content:theText, subject:theTitle}
	open newmail
	delay 1
	tell application "System Events"
		keystroke "a" using command down
		keystroke "x" using command down
		keystroke "v" using {command down, option down, shift down}
	end tell
end tell