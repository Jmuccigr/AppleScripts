-- Left-right center images using imagemagick
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set ct to the count of finderObjects
	set fuzz to 25
	if ct < 4 then
		set show to true
	else
		set show to false
	end if
	if shift_down of modifierKeysPressed() then set show to not show
	repeat with filename in (finderObjects)
		set tiff to ""
		set fname to quoted form of POSIX path of filename
		tell application "Finder"
			set ext to name extension of filename
			if ext in {"tif", "tiff"} then
				set tiff to " -compress " & (do shell script "/usr/local/bin/identify -format \"%C\" " & fname)
				if tiff contains "Group4" then set tiff to " -alpha off -monochrome -compress Group4 -quality 100 "
			end if
		end tell
		set qual to (do shell script "/usr/local/bin/identify -format \"%Q\" " & fname)
		do shell script "orig_dim=($(/usr/local/bin/magick " & fname & " -shave 10x10 -bordercolor white -border 10x10 -blur 0,8 -normalize -fuzz " & fuzz & "% -trim -format " & quote & "%W %H %X %Y %w" & quote & " info:)); w=${orig_dim[0]}; h=${orig_dim[1]}; x=${orig_dim[2]}; y=${orig_dim[3]}; new_w=${orig_dim[4]}; x_dis=$(( (w - new_w) / 2)); /usr/local/bin/magick \\( -size " & quote & "$w" & quote & "x$h -background white xc: -write mpr:bgimage +delete \\) mpr:bgimage \\( " & fname & " -crop " & quote & "$w" & quote & "x$h+$x+$y  \\) -compose divide_dst -gravity northwest -geometry +$x_dis+$y -composite" & tiff & " -quality " & qual & " $TMPDIR/tempfile." & ext
		tell application "Finder"
			delete file filename
			do shell script "mv $TMPDIR/tempfile." & ext & " " & fname
			if show then
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
