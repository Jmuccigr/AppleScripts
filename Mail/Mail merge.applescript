-- Send email using the clipboard
-- Format of clipboard should be tab-separated columns
-- First is email address; last is message content

set maillist to the clipboard
set maillist to the paragraphs of maillist
set origin to (choose from list {"jmuccigr@drew.edu", "muccigrosso@icloud.com"} with title "Pick sender's address" with prompt "Please choose the addres to send the messages from")
if origin is "" then error number -128
set origin to "John Muccigrosso <" & origin & ">"
set subj to text returned of (display dialog "Enter subject line" default answer "subject" with icon note)
set contentPrefix to text returned of (display dialog "Enter text to prefix to the message content" default answer "" with icon note)
set contentSuffix to text returned of (display dialog "Enter text to append to the message content" default answer "" with icon note)
repeat with person in maillist
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to tab
	if person as string is not "" then
		set add to text item 1 of person
		set msg to contentPrefix & space & the last text item of person & contentSuffix
		set AppleScript's text item delimiters to tid
		tell application "Mail"
			activate
			set theMessage to make new outgoing message with properties {subject:subj, content:msg, visible:true, message signature:signature named "Drew", sender:origin}
			tell theMessage to make new to recipient with properties {address:add}
		end tell
	end if
end repeat
end

