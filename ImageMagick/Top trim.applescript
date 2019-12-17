-- Trim top side of images using imagemagick
-- Chop off 3% of pixels, trim, and then add a white border to the result
-- If the option key is down, shrink the chopped region to only .5%
-- If the command key is down, restore the image to its original size

on open of finderObjects
	set border to "3"
	set restore to false
	set pct to "3"
	
	if option_down of modifierKeysPressed() then
		set pct to ".5"
		beep
	end if
	if command_down of modifierKeysPressed() then
		set restore to true
		beep 2
	end if
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		-- Get size of strip to be removed
		set strip to do shell script "$(bash -l -c 'which magick') " & fname & " -format " & quote & "%[fx:max(5,ceil(h*" & pct & "/100))]\" info:"
		-- Get crop numbers only if we're going to restore the image size
		if restore then
			-- Set the border to 0 because we're restoring the original size
			set border to 0
			-- Get the geometry so we can restore the original size
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to ","
			set {dims, inset} to the text items of (do shell script "$(bash -l -c 'which magick') " & fname & " -gravity north -chop 0x" & strip & " -fuzz 2% -trim -format " & quote & "%P,%O" & quote & " info:")
			set AppleScript's text item delimiters to tid
		end if
		-- Make the script wait for magick to finish
		set thePID to (do shell script "$(bash -l -c 'which magick') " & fname & " +repage -gravity north -chop 0x" & strip & " -fuzz 2% -trim -bordercolor white -border " & border & " +repage $TMPDIR/tempfile.png")
		--		error number -128
		repeat
			do shell script "ps ax | grep " & thePID & " | grep -v grep | awk '{ print $1 }'"
			if result is "" then exit repeat
			delay 0.2
		end repeat
		if restore then
			-- composite the tmpfile onto a white file of the size of the original, determined above.
			-- should be able to combine this with the step above as a final process. Init var to "" or set to the extra command stuff if needed
			do shell script "$(bash -l -c 'which magick') \\( -background white -size " & dims & " xc: \\) $TMPDIR/tempfile.png -geometry " & inset & " -compose divide_dst -composite -splice 0x" & strip & " $TMPDIR/tempfile.png"
		end if
		
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
