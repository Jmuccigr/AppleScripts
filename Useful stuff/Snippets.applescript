
(*
-- Get info on front window of app
try
	-- First try the usual AS method
	tell application (path to frontmost application as text) -- or just use the application name directly
		set fpath to (path of document 1) as text
		set fname to (name of document 1) as text
	end tell
on error
	-- Then if it doesn't work because the app doesn't support applescript
	try
		tell application "System Events" to tell (process 1 where frontmost is true)
			set fpath to value of attribute "AXDocument" of window 1
			set fname to value of attribute "AXTitle" of window 1
		end tell
	end try
end try
*)

display dialog my replace("hello", "l", "p")

-- Quick search and replace with TID
on replace(origtext, ftext, rtext)
	set tid to AppleScript's text item delimiters
	set newtext to origtext
	set AppleScript's text item delimiters to ftext
	set newtext to the text items of newtext
	set AppleScript's text item delimiters to rtext
	set newtext to the text items of newtext as string
	set AppleScript's text item delimiters to tid
	return newtext
end replace