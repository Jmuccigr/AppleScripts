-- Trim images using imagemagick
-- Trim and then add a white border to the result
-- If the option key is down, be more aggressive in matching the pixels for trimming
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set ct to the count of finderObjects
	if shift_down of modifierKeysPressed() then
		if ct > 3 then
			set ct to 0
		else
			set ct to 4
		end if
	end if
	
	set border to "3"
	
	if option_down of modifierKeysPressed() then
		set pct to "5%"
		beep
	else
		set pct to "2%"
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "$(bash -l -c 'which convert') +repage -fuzz " & pct & " -trim -bordercolor white -border " & border & " +repage " & fname & " $TMPDIR/tempfile.png"
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
