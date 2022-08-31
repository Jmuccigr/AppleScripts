on open fList
	# Just assuming that the files are all images at this point.
	
	# Need more than 1 file for this to make sense
	if number of items of fList is 1 then
		display alert "Only one file!" message "This only makes sense with more than one file."
		quit
	end if
	
	# Set some variables, including output file name with date/time string
	set dest to ""
	set fListP to ""
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set extList to {"png", "jpg", "jpeg", "tif", "tiff", "bmp", "ccit", "gif", "pict"}
	set format to ""
	
	# Default is to append images top to bottom. Option key makes it left to right.
	if option_down of modifierKeysPressed() then
		set sign to "+"
		beep
	else
		set sign to "-"
	end if
	# Default is to take files in order in which they are given. Command key reverses that.
	if command_down of modifierKeysPressed() then
		set reverseOrder to true
		beep 2
	else
		set reverseOrder to false
	end if
	
	# String names together for magick and grab the dir while we're at it.
	repeat with fName in fList
		if dest = "" then # it's the first file in the list
			tell application "Finder"
				set dest to the quoted form of the POSIX path of ((the container of fName) as string)
				set ext to (name extension of fName) as string
			end tell
		end if
		if not reverseOrder then
			set fListP to fListP & " " & the quoted form of the POSIX path of fName
		else
			set fListP to the quoted form of the POSIX path of fName & " " & fListP
		end if
	end repeat
	
	# Check on image format choice
	repeat until format is in extList
		if format ­ "" then display alert "Unknown extension" message "That extension is not recognized. Please try another."
		set dialogResult to (display dialog "The default format for the output is the same as that of the first image in the list. If you want to change it, enter a new file extension here. (No checking is done.)" buttons {"Cancel", "Force grayscale", "Original color"} default button 3 with title "Output format" with icon note default answer ext)
		set format to text returned of dialogResult
	end repeat
	set colorChoice to button returned of dialogResult
	
	# Check on colorspace choice
	if colorChoice = "Force grayscale" then
		set formatString to " -colorspace gray "
	else
		set formatString to ""
	end if
	
	# Do it
	do shell script "/opt/homebrew/bin/magick " & fListP & " " & sign & "append " & formatString & dest & dateString & "." & format
end open

use framework "Foundation"
use framework "AppKit"

on modifierKeysPressed()
	set modifierKeysDOWN to {command_down:false, option_down:false, control_down:false, shift_down:false}
	
	set |‰Î÷| to current application
	set currentModifiers to |‰Î÷|'s class "NSEvent"'s modifierFlags()
	
	tell modifierKeysDOWN
		set its option_down to (currentModifiers div (get |‰Î÷|'s NSAlternateKeyMask) mod 2 is 1)
		set its command_down to (currentModifiers div (get |‰Î÷|'s NSCommandKeyMask) mod 2 is 1)
		set its shift_down to (currentModifiers div (get |‰Î÷|'s NSShiftKeyMask) mod 2 is 1)
		set its control_down to (currentModifiers div (get |‰Î÷|'s NSControlKeyMask) mod 2 is 1)
	end tell
	
	return modifierKeysDOWN
end modifierKeysPressed

modifierKeysPressed()
