-- Trim images using imagemagick
-- Remove a border around the image, trim and then add back a white border to the result
-- If the option key is down, be more aggressive in matching the pixels for trimming
-- If the command key is down, restore the image to its original size
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set filePath to POSIX path of (path to documents folder) & "colormaps/"
	set border to "10"
	set frame to "3"
	set restore to false
	set ct to the count of finderObjects
	
	if shift_down of modifierKeysPressed() then
		if ct > 3 then
			set ct to 0
		else
			set ct to 4
		end if
	end if
	if option_down of modifierKeysPressed() then
		set pct to "40%"
		beep
	else
		set pct to "15%"
	end if
	if command_down of modifierKeysPressed() then
		set restore to true
		beep 2
	end if
	-- Ask about trimming
	set reply to (display dialog "How many pixels to shave from each side before starting?" buttons {"OK", "None", "Cancel"} default button 2 default answer "10")
	set clipBorder to the button returned of reply
	if clipBorder = "OK" then
		set border to text returned of reply
		set borderTrim to " -shave " & border & " +repage "
	else
		set borderTrim to ""
		set border to 0
	end if
	
	-- Ask about final border
	if button returned of (display dialog "Add a white border when finished?" buttons {"Yes", "No"} default button 2) = "Yes" then
		set addWhite to " -bordercolor white -border " & frame & "x" & frame
	else
		set addWhite to ""
	end if
	
	-- Ask whether to do a simple trim
	if button returned of (display dialog "Just trim or be smarter about it?" buttons {"Just do it", "Be smart"} default button 2) = "Be smart" then
		set simple to false
	else
		set simple to true
	end if
	-- Ask what kind of image for smart trim
	if not simple then
		set rep to button returned of (display dialog "Is this a Black & White, Grayscale or Color image?" buttons {"Black & White", "Grayscale", "Color"} default button 3)
		if rep = "Black & White" then
			set remapFile to "2.gif"
		else if rep = "Grayscale" then
			set remapFile to "3_lighter.gif"
		else
			set remapFile to "5_color.gif"
		end if
	end if
	
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		tell application "Finder" to set ext to the name extension of filename
		if ext contains "tif" then
			set tiff to " -define tiff:preserve-compression=true "
		else
			set tiff to ""
		end if
		if restore then
			-- Get the geometry so we can restore the original size. Add back shaved border after info:
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to ","
			set {dims, inset} to the text items of (do shell script "/usr/local/bin/magick " & fname & " -shave " & border & " -fuzz " & pct & " -trim -format " & quote & "%P,%O" & quote & " info:")
			set AppleScript's text item delimiters to "x"
			set wid to (((text item 1 of dims) as number) + 2 * border) as text
			set len to (((text item 2 of dims) as number) + 2 * border) as text
			set origDims to wid & "x" & len
			set AppleScript's text item delimiters to tid
		end if
		-- Make the script wait for magick to finish
		if simple then
			set thePID to (do shell script "/usr/local/bin/magick " & fname & tiff & borderTrim & " -fuzz " & pct & " -trim " & addWhite & " +repage $TMPDIR/tempfile." & ext)
			repeat
				do shell script "ps ax | grep " & thePID & " | grep -v grep | awk '{ print $1 }'"
				if result is "" then exit repeat
				delay 0.2
			end repeat
		else
			set thePID to (do shell script "/usr/local/bin/magick " & fname & tiff & " -crop `/usr/local/bin/magick " & fname & borderTrim & " -blur 0x2 +dither -remap " & filePath & remapFile & " -fuzz " & pct & " -trim -format %wx%h+%[fx:page.x+" & border & "]+%[fx:page.y+" & border & "] info:` " & addWhite & " +repage $TMPDIR/tempfile." & ext)
			repeat
				do shell script "ps ax | grep " & thePID & " | grep -v grep | awk '{ print $1 }'"
				if result is "" then exit repeat
				delay 0.2
			end repeat
		end if
		if restore then
			-- composite the tmpfile onto a white file of the size of the cropped version, the put that onto one of original size, determined above.
			-- should be able to combine this with the step above as a final process. Init var to "" or set to the extra command stuff if needed
			do shell script "/usr/local/bin/magick \\( -background white -size " & dims & " xc: \\) $TMPDIR/tempfile." & ext & " -geometry " & inset & " -compose divide_dst -composite $TMPDIR/tempfile." & ext
			do shell script "/usr/local/bin/magick \\( -background white -size " & origDims & " xc: \\) $TMPDIR/tempfile." & ext & " -geometry +" & border & "+" & border & " -compose divide_dst -composite $TMPDIR/tempfile." & ext
		end if
		
		tell application "Finder"
			delete file filename
			do shell script "cp $TMPDIR/tempfile." & ext & space & fname
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
