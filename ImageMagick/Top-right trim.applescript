-- Trim bottom-right corner of images using imagemagick
-- Blank out a square 5% in size, trim image, and then add a white border to the result
-- If the option key is down, shrink the square to only 1%

on open of finderObjects
	set border to "3"
	
	if option_down of modifierKeysPressed() then
		set pct to 2
		beep
	else
		set pct to 5
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "size=`/usr/local/bin/convert " & fname & " -format " & quote & "%[fx:" & pct & "*min(w,h)/100]" & quote & " info:`
/usr/local/bin/convert +repage " & fname & " \\( -size ${size}x${size} -background white xc: \\) -gravity northeast -compose over -composite -fuzz 2% -trim -bordercolor white -border " & border & " +repage $TMPDIR/tempfile.png"
		tell application "Finder"
			delete file filename
			do shell script "cp $TMPDIR/tempfile.png " & fname
			do shell script "qlmanage -p " & fname
			select file filename
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
