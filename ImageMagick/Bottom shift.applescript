-- Shift images to the bottom using imagemagick
-- Chop off 3% of pixels on one side, and then add a white border of the same size to the opposite side
-- If the option key is down, increase the chopped region to 10%
-- If the command key is down, re-splice the chopped region, effectively erasing it
-- There are better ways to do that, but this keeps the scripting simple.

on open of finderObjects
	
	if option_down of modifierKeysPressed() then
		set pct to "10"
		beep
	else
		set pct to "3"
	end if
	if command_down of modifierKeysPressed() then
		set side to "south"
		beep 2
	else
		set side to "north"
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "lh=`/usr/local/bin/identify -format %h " & fname & "`; lh=$(( lh * " & pct & "/100 ));
		$(bash -l -c 'which convert') +repage -gravity south -chop 0x${lh} -gravity " & side & " -background white -splice 0x${lh} +repage " & fname & " $TMPDIR/tempfile.png"
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
