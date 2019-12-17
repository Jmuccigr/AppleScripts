-- Trim right side of images using imagemagick
-- Chop off 4% of pixels, trim, and then add a white border to the result
-- If the option key is down, shrink the chopped region to only .5%

on open of finderObjects
	set ct to the count of finderObjects
	set border to "3"
	
	if option_down of modifierKeysPressed() then
		set pct to ".5"
		beep
	else
		set pct to "4"
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "lw=`$(bash -l -c 'which magick') " & fname & " -format " & quote & "%[fx:max(5,ceil(w*" & pct & "/100))]\" info:`; \n\t\t$(bash -l -c 'which magick') " & fname & " +repage -gravity east -chop ${lw}x0 -fuzz 2% -trim -bordercolor white -border " & border & " +repage $TMPDIR/tempfile.png"
		tell application "Finder"
			delete file filename
			do shell script "cp $TMPDIR/tempfile.png " & fname
			if ct < 4 then
				do shell script "qlmanage -p " & fname
			end if
			select file filename
		end tell
	end repeat
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
