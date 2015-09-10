-- Based on a script by
-- Hareem Adderley, March 19,2013, Kingpin Apps  www.kingpinapps.com
-- http://community.spiceworks.com/scripts/show/1874-flagged-to-reminders-app

-- Script to turn the currently selected messages into Reminders.
-- Reminder list and delay until reminder are set at the top.

on run
	
	set theMessages to {}
	set formatBody to ""
	set interval to 5 * hours
	set reminderList to "Reminders"
	
	tell application "Mail"
		set theMessages to the selection
		if (theMessages = {} or the class of item 1 of theMessages is not message) then display alert "No message selected"
		repeat with i in the items of theMessages
			set fromMsg to (sender of i as string)
			set subjMsg to (subject of i as string)
			set msgID to message id of i
			set msgBody to content of i
			set formatBody to paragraph 1 of msgBody & return & paragraph 2 of msgBody & return & paragraph 3 of msgBody
			
			tell application "Reminders"
				make new reminder in list reminderList with properties {name:subjMsg, body:"From: " & fromMsg & formatBody & "message://%3c" & msgID & "%3e", due date:((current date) + interval)}
			end tell
		end repeat
	end tell
	
end run