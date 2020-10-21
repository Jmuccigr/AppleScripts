-- Error to cancel script
error number -128

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


do shell script "i=" & posixfilename & ";echo $(i##*.)"
-- filename=$(basename -- "$fullfile")
-- extension="${filename##*.}"
-- filename="${filename%.*}"

get running of application "Finder"

-- Check for existence of file
-- returns true if file exists, an error if it doesn't
theFileName as alias
-- For a POSIX path, where thePath is not quoted and ends in /
-- Missing file returns an error, so use 'on error' not 'else'
exists POSIX file thePath as alias


# Create likely unique name for destination folder using date and time
tell application "Finder"
	set fnameString to characters 1 thru 15 of (((name of file fname) as string) & "              ") as string
	set fnameString to (do shell script "echo " & quoted form of fnameString & " | tr ' ' '_'")
end tell
set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
# Get info on the file to combine for path and name
set pfile to the POSIX path of fname
set fpath to (do shell script "dirname " & quoted form of pfile) & "/" & dateString & "_" & fnameString & "_images"

-- To handle POSIX file paths, append "as alias" to "POSIX file theFile"

(*
-- Check for modifier keys, from http://macscripter.net/viewtopic.php?id=33652

use framework "Foundation"
use framework "AppKit"

on modifierKeysPressed()
Ê Êset modifierKeysDOWN to {command_down:false, option_down:false, control_down:false, shift_down:false}
Ê Ê
Ê Êset |‰Î÷| to current application
Ê Êset currentModifiers to |‰Î÷|'s class "NSEvent"'s modifierFlags()
Ê Ê
Ê Êtell modifierKeysDOWN
Ê Ê Ê Êset its option_down to (currentModifiers div (get |‰Î÷|'s NSAlternateKeyMask) mod 2 is 1)
Ê Ê Ê Êset its command_down to (currentModifiers div (get |‰Î÷|'s NSCommandKeyMask) mod 2 is 1)
Ê Ê Ê Êset its shift_down to (currentModifiers div (get |‰Î÷|'s NSShiftKeyMask) mod 2 is 1)
Ê Ê Ê Êset its control_down to (currentModifiers div (get |‰Î÷|'s NSControlKeyMask) mod 2 is 1)
Ê Êend tell
Ê Ê
Ê Êreturn modifierKeysDOWN
end modifierKeysPressed

modifierKeysPressed()
*)

-- Another method for same

property vers : "1.0"

isModifierKeyPressed("")
on isModifierKeyPressed(checkKey)
	set modiferKeysDOWN to {command_down:false, option_down:false, control_down:false, shift_down:false, caps_down:false, numlock_down:false, function_down:false}
	
	if checkKey = "" or checkKey = "option" or checkKey = "alt" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSAlternateKeyMask '") > 1 then
			set option_down of modiferKeysDOWN to true
		end if
	end if
	
	if checkKey = "" or checkKey = "command" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSCommandKeyMask '") > 1 then
			set command_down of modiferKeysDOWN to true
		end if
	end if
	
	if checkKey = "" or checkKey = "shift" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSShiftKeyMask '") > 1 then
			set shift_down of modiferKeysDOWN to true
		end if
	end if
	
	if checkKey = "" or checkKey = "control" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSControlKeyMask '") > 1 then
			set control_down of modiferKeysDOWN to true
		end if
	end if
	
	if checkKey = "" or checkKey = "caps" or checkKey = "capslock" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSAlphaShiftKeyMask '") > 1 then
			set caps_down of modiferKeysDOWN to true
		end if
	end if
	
	if checkKey = "" or checkKey = "numlock" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSNumericPadKeyMask'") > 1 then
			set numlock_down of modiferKeysDOWN to true
		end if
	end if
	--Set if any key in the numeric keypad is pressed. The numeric keypad is generally on the right side of the keyboard. This is also set if any of the arrow keys are pressed
	
	if checkKey = "" or checkKey = "function" or checkKey = "func" or checkKey = "fn" then
		if (do shell script "/usr/bin/python -c 'import Cocoa; print Cocoa.NSEvent.modifierFlags() & Cocoa.NSFunctionKeyMask'") > 1 then
			set function_down of modiferKeysDOWN to true
		end if
	end if
	--Set if any function key is pressed. The function keys include the F keys at the top of most keyboards (F1, F2, and so on) and the navigation keys in the center of most keyboards (Help, Forward Delete, Home, End, Page Up, Page Down, and the arrow keys)
	
	return modiferKeysDOWN
end isModifierKeyPressed

-- Use Image Events app to work with images. It has no user interaction, so can't display things
on getDims(fileName)
	tell application "Image Events"
		set i to open fileName
		set d to the dimensions of i & (the file type of i as string)
	end tell
	return d
end getDims

-- Notify of completion
display notification ("message.") with title "title" sound name "beep"
