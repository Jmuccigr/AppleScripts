-- Change the resolution of images so they'll fit on 8.5x11 or A4 paper without changes using imagemagick
-- Esp. helpful if you're converting them to PDF
-- If the option key is down, do a the "close enough" check (= leave pages within 1%)
-- Changes the files in place, since this is not irreversible.


on open of finderObjects
	-- Need this before the loop or else you have to keep the option key down for all files
	if option_down of modifierKeysPressed() then
		set checkSize to true
		beep
	else
		set checkSize to false
	end if
	repeat with filename in (finderObjects)
		set closeEnough to false
		tell application "Finder" to set ext to (name extension of filename) as string
		if ext is in {"tiff", "tif"} then
			set extraflag to " -define tiff:preserve-compression=true "
		else
			set extraflag to " "
		end if
		tell application "Image Events"
			set i to open filename
			set {wid, ht, dimx, dimy} to (the dimensions of i & the resolution of i)
		end tell
		display dialog {wid, " ", ht, " ", dimx, " ", dimy} as string
		set fname to quoted form of POSIX path of filename
		-- Calculate new resolution in cm
		set resW to wid / 8 as integer
		set resH to ht / 10.5 as integer
		display dialog (resW & space & resH) as string
		if checkSize then
			-- Don't do anything if the dimensions are close enough
			if ((resW < dimx * 1.01 and resW > 0.99 * dimx) and (resH < dimy * 1.01 and resH > 0.99 * dimy)) then set closeEnough to true
		end if
		if not closeEnough then
			if resW > resH then
				set dimNew to resW
			else
				set dimNew to resH
			end if
			do shell script "/usr/local/bin/magick mogrify -units PixelsPerInch -density " & dimNew & "x" & dimNew & extraflag & fname
		end if
	end repeat
	display notification "Your files now all will fit natively on a page." with title "Resolution adjustment complete" sound name "default"
end open

use framework "Foundation"
use framework "AppKit"

on modifierKeysPressed()
	set modifierKeysDOWN to {command_down:false, option_down:false, control_down:false, shift_down:false}
	
	set |���| to current application
	set currentModifiers to |���|'s class "NSEvent"'s modifierFlags()
	
	tell modifierKeysDOWN
		set its option_down to (currentModifiers div (get |���|'s NSAlternateKeyMask) mod 2 is 1)
		set its command_down to (currentModifiers div (get |���|'s NSCommandKeyMask) mod 2 is 1)
		set its shift_down to (currentModifiers div (get |���|'s NSShiftKeyMask) mod 2 is 1)
		set its control_down to (currentModifiers div (get |���|'s NSControlKeyMask) mod 2 is 1)
	end tell
	
	return modifierKeysDOWN
end modifierKeysPressed

modifierKeysPressed()
