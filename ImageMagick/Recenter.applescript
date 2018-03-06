-- Left-right center images using imagemagick
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
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "orig_dim=($(/usr/local/bin/convert " & fname & " -shave 10x10 -bordercolor white -border 10x10 -blur 0,8 -normalize -fuzz 2% -trim -format " & quote & "%W %H %X %Y %w" & quote & " info:)); w=${orig_dim[0]}; h=${orig_dim[1]}; x=${orig_dim[2]}; y=${orig_dim[3]}; new_w=${orig_dim[4]}; echo $w; x_dis=$(( (w - new_w) / 2)); /usr/local/bin/convert \\( -size " & quote & "$w" & quote & "x$h -background white xc: -write mpr:bgimage +delete \\) mpr:bgimage \\( -crop " & quote & "$w" & quote & "x$h+$x+$y " & fname & " \\) -compose divide_dst -gravity northwest -geometry +$x_dis+$y -composite $TMPDIR/tempfile.png"
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
