tell application "Safari"
	activate
	set theURL to URL of current tab of window 1
	set theTitle to name of current tab of window 1
end tell

tell application "Microsoft Outlook"
	activate
	set newmail to make new outgoing message with properties {plain text content:theURL, subject:theTitle}
	open newmail
end tell