-- Change the resolution of images so they'll fit on 8.5x11 paper without changes using imagemagick
-- Esp. helpful if you're converting them to PDF
-- If the option key is down, ignore the "close enough" check (= force change)
-- Changes the files in place, since this is not irreversible.

set extraflag to " "

on open of finderObjects
	-- Need this before the loop or else you have to keep the option key down for all files
	if option_down of modifierKeysPressed() then
		set checkSize to false
		beep
	else
		set checkSize to true
	end if
	repeat with filename in (finderObjects)
		set closeEnough to false
		tell application "Finder"
			set ext to (name extension of filename) as string
		end tell
		if ext is in {"tiff", "tif"} then set extraflag to " -define tiff:preserve-compression=true "
		set fname to quoted form of POSIX path of filename
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to " "
		set {wid, ht, dimx, dimy} to the text items of (do shell script "/usr/local/bin/magick " & fname & " -format " & quote & "%W %H %x %y" & quote & " info:")
		set AppleScript's text item delimiters to tid
		-- Calculate new resolution in cm
		set resW to wid / (8 * 2.54)
		set resH to ht / (10.5 * 2.54)
		if checkSize then
			-- Don't do anything if the dimensions are close enough
			if ((resW < dimx * 1.01 and resW > 0.9 * dimx) and (resH < dimy * 1.01 and resH > 0.9 * dimy)) then set closeEnough to true
		end if
		if not closeEnough then
			if resW > resH then
				set dimNew to resW
			else
				set dimNew to resH
			end if
			do shell script "/usr/local/bin/magick mogrify -units PixelsPerCentimeter -density " & dimNew & "x" & dimNew & extraflag & fname --& "& " $TMPDIR/tempfile." & ext
		end if
	end repeat
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
