
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


-- Get user directory paths
set myHome to POSIX path of (path to home folder)
set myDocs to POSIX path of (path to documents folder)
set myLib to POSIX path of (path to library folder from user domain)

-- Count characters in a text
on countchar(origtext, ch)
	set theCount to (count items of origtext)
	set {oldtids, my text item delimiters} to {my text item delimiters, ch}
	set keyCount to (count text items of origtext) - 1
	set my text item delimiters to oldtids
	return keyCount
end countchar

-- Get filename without extension
on getName(fileName)
	set delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "."
	if fileName contains "." then set fileName to (text items 1 thru -2 of fileName) as text
	set AppleScript's text item delimiters to delims
	return fileName
end getName


get running of application "Finder"

-- Check for existence of file
-- returns true if file exists
theFileName as alias
-- For a POSIX path, where thePath is not quoted and ends in /
-- Missing file returns an error, so use 'on error' not 'else'
exists POSIX file thePath as alias

-- To handle POSIX file paths, append "as alias" to "POSIX file theFile"