-- Shift images to the left using imagemagick
-- Chop off 3% of pixels on one side, and then add a white border of the same size to the opposite side
-- If the option key is down, increase the chopped region to 10%
-- If the command key is down, re-splice the chopped region, effectively erasing it
-- There are better ways to do that, but this keeps the scripting simple
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set ct to the count of finderObjects
	if option_down of modifierKeysPressed() then
		set pct to "10"
		beep
	else
		set pct to "3"
	end if
	if command_down of modifierKeysPressed() then
		set side to "west"
		beep 2
	else
		set side to "east"
	end if
	if shift_down of modifierKeysPressed() then
		if ct > 3 then
			set ct to 0
		else
			set ct to 4
		end if
	end if
	repeat with filename in (finderObjects)
		tell application "Finder" to set ext to the name extension of filename
		if ext contains "tif" then
			set tiff to " -define tiff:preserve-compression=true "
			set newExt to "tiff"
			set comp to (do shell script "/opt/homebrew/bin/identify -format %C " & quoted form of POSIX path of filename)
			if comp = "Group4" then
				set comp to " -alpha off -monochrome -compress Group4 -quality 100 "
			else
				set comp to " -compress " & comp & " "
			end if
		else
			set tiff to ""
			set comp to ""
			set newExt to "png"
		end if
		set fname to quoted form of POSIX path of filename
		do shell script "lw=`/opt/homebrew/bin/identify -format %w " & fname & "`; lw=$(( lw * " & pct & "/100 ));\n\t\t$(bash -l -c 'which magick') " & fname & " +repage -gravity west -chop ${lw}x0 -gravity " & side & " -background white -splice ${lw}x0 +repage " & comp & "$TMPDIR/tempfile." & newExt
		tell application "Finder"
			delete file filename
			if ext ­ "png" then
				do shell script "$(bash -l -c 'which magick') $TMPDIR/tempfile." & newExt & " -format " & ext & " " & tiff & fname
			else
				do shell script "cp $TMPDIR/tempfile." & newExt & " " & fname
			end if
			if ct < 4 then
				do shell script "qlmanage -p " & fname
				select file filename
			end if
		end tell
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
