-- Set all images to the size of the largest in the group using imagemagick
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set ct to the count of finderObjects
	if ct = 1 then
		display alert "No point!" message "This process requires more than one file to work on."
		error -128
	end if
	if shift_down of modifierKeysPressed() then
		if ct > 3 then
			set ct to 0
		else
			set ct to 4
		end if
	end if
	set w to 0
	set h to 0
	set changed to false
	-- First loop through to get the dimensions
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		set tiff to ""
		set {newW, newH, comp} to the words of (do shell script "/usr/local/bin/identify -format \"%w, %h, %C\" " & fname)
		tell application "Finder"
			set ext to name extension of filename
			if ext contains "tif" then
				set tiff to " -compress " & comp
			end if
		end tell
		if (newW > w) then
			if w ­ 0 then set changed to true
			set w to newW
		end if
		if (newH > h) then
			if h ­ 0 then set changed to true
			set h to newH
		end if
	end repeat
	if not changed then
		display alert "No need!" message "All of these files are already the same size. Exiting..."
		error -128
	end if
	-- Now loop through to change the files
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script ("/usr/local/bin/magick \\( -size \"" & w & "\"x\"" & h & "\" -background white xc: -write mpr:bgimage +delete \\) mpr:bgimage -gravity center -geometry +0+0 " & fname & " -compose divide_dst " & tiff & " -composite $TMPDIR/tempfile." & ext)
		tell application "Finder"
			delete file filename
			do shell script "cp $TMPDIR/tempfile." & ext & " " & fname
			if ct < 4 then
				do shell script "qlmanage -p " & fname
				select file filename
			end if
		end tell
	end repeat
end open

display notification "Done!" with title "Maximizing complete" subtitle "Processing is complete." sound name default

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
