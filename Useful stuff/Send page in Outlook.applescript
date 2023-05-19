tell application "Safari"
	activate
	set theURL to URL of current tab of window 1
	set theTitle to name of current tab of window 1
	set theText to ""
	set theText to (do JavaScript "window.getSelection().toString();" in current tab of window 1)
	if theText is not "" then set allText to theURL & "<br><br>" & theText
end tell

tell application "Microsoft Outlook"
	activate
	set newmail to make new outgoing message with properties {content:allText, subject:theTitle}
	open newmail
end tell