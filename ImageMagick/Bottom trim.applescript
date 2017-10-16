-- Trim bottom side of images using imagemagick
-- Chop off 3% of pixels, trim, and then add a white border to the result
-- If the option key is down, shrink the chopped region to only .5%

on open of finderObjects
	set border to "3"
	
	if option_down of modifierKeysPressed() then
		set pct to "0.5"
		beep
	else
		set pct to "3"
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "lh=`/usr/local/bin/convert " & fname & " -format " & quote & "%[fx:max(5,ceil(h*" & pct & "/100))]\" info:`; 
		/usr/local/bin/convert +repage -gravity south -chop 0x${lh} -fuzz 2% -trim -bordercolor white -border " & border & " +repage " & fname & " $TMPDIR/tempfile.png"
		--		do shell script "lh=`/usr/local/bin/convert " & fname & " -format " & quote & "%[fx:ceil(w*" & pct & "/100)]\" info:`; osascript -e \"display dialog  \"$lh\"\";" #/usr/local/bin/convert +repage -gravity south -chop 0x${lh} -fuzz 2% -trim -bordercolor white -border 3 +repage " & fname & " $TMPDIR/tempfile.png"
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
