-- Change the resolution of images so they'll fit on 8.5x11 or A4 paper without changes using imagemagick
-- Esp. helpful if you're converting them to PDF
-- If the option key is down, do a the "close enough" check (= leave pages within 1%)
-- Changes the files in place, since this is not irreversible.


on open finderObjects
	-- Need this before the loop or else you have to keep the option key down for all files
	if option_down of modifierKeysPressed() then
		set checkSize to true
		beep
	else
		set checkSize to false
	end if
	repeat with filename in (finderObjects)
		set closeEnough to false
		tell application "Finder" to set ext to the name extension of filename
		if ext is in {"jpg", "jpeg"} then
			set jpg to true
		else
			set jpg to false
		end if
		tell application "Finder" to set ext to (name extension of filename) as string
		if not jpg then
			set extraflag to " -define tiff:preserve-compression=true "
		else
			set extraflag to " "
		end if
		if not jpg then
			tell application "Image Events"
				set i to open filename
				set {wid, ht, dimx, dimy} to (the dimensions of i & the resolution of i)
				set multiplier to 1
			end tell
		else
			try
				set exifresponse to the words of (do shell script "/usr/local/bin/exiftool -s3 -t -ImageWidth -ImageHeight -exif:xresolution -exif:yresolution -exif:resolutionunit " & the quoted form of the POSIX path of filename)
			on error errMsg number errNum
				display alert "exiftool error " & errNum message errMsg
				error number -128
			end try
			if the number of items of exifresponse ³ 4 then
				set {wid, ht, dimx, dimy, units} to exifresponse
				if units ­ "inches" then
					set multiplier to 2.54
				else
					set multiplier to 1
				end if
			else
				tell application "Image Events"
					set i to open filename
					set {wid, ht, dimx, dimy} to (the dimensions of i & the resolution of i)
					set multiplier to 1
				end tell
			end if
		end if
		set fname to quoted form of POSIX path of filename
		-- Calculate new resolution in inches
		set resW to wid * multiplier / 8 as integer
		set resH to ht * multiplier / 10.5 as integer
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
			-- Change exif data for jpeg as well as the other density data
			if jpg then do shell script "/usr/local/bin/exiftool -preserve -overwrite_original_in_place -units=inches -xresolution=" & dimNew & " -yresolution=" & dimNew & " " & the quoted form of the POSIX path of filename
			do shell script "/usr/local/bin/magick mogrify -units PixelsPerInch -density " & dimNew & "x" & dimNew & extraflag & fname
		end if
	end repeat
	display notification "Your files now all will fit natively on a page." with title "Resolution adjustment complete" sound name "default"
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
