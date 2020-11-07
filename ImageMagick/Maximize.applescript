-- Set all images to the size of the largest in the group using imagemagick
-- If the shift key is down, the quicklook behavior is reversed

on open of finderObjects
	set ct to the count of finderObjects
	if ct = 1 then
		display alert "No point!" message "This process requires more than one file to work on."
		error number -128
	end if
	if ct < 4 then
		set show to true
	else
		set show to false
	end if
	if shift_down of modifierKeysPressed() then set show to not show
	set w to 0
	set h to 0
	set changed to false
	-- First loop through to get the dimensions
	repeat with filename in (finderObjects)
		set {newW, newH, ft} to getDims(filename)
		if not changed then
			if (newW ≠ w or newH ≠ h) and w ≠ 0 then set changed to true
			--if ((w * h) / (newW * newH) ≠ 1) and w ≠ 0 then set changed to true
		end if
		if (newW > w) then set w to newW
		if (newH > h) then set h to newH
	end repeat
	if not changed then
		display alert "No need!" message "All of these files are already the same size. Exiting..."
		error number -128
	end if
	-- Now loop through to change the files
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		set {docW, docH, comp} to the words of (do shell script "/usr/local/bin/identify -format \"%w, %h, %C\" " & fname)
		tell application "Finder" to set ext to the name extension of filename
		if ext contains "tif" then
			set tiff to " -quality 100 -compress " & comp
		else
			set tiff to ""
		end if
		if ((docW & " " & docH) as string ≠ (w & " " & h) as string) then
			set addWwest to (w - docW) / 2 as integer
			set addWeast to w - docW - addWwest
			set addHnorth to (h - docH) / 2 as integer
			set addHsouth to h - docH - addHnorth
			--do shell script ("/usr/local/bin/magick \\( -size \"" & w & "\"x\"" & h & "\" -background white xc: -write mpr:bgimage +delete \\) mpr:bgimage -gravity center -geometry +0+0 " & fname & " -compose divide_dst " & tiff & " -composite $TMPDIR/tempfile." & ext)
			do shell script ("/usr/local/bin/magick " & fname & " -background white -gravity north -splice 0x" & addHnorth & " -gravity south -splice 0x" & addHsouth & " -gravity west -splice " & addWwest & "x0  -gravity east -splice " & addWeast & "x0 " & tiff & " $TMPDIR/tempfile." & ext)
			tell application "Finder"
				delete file filename
				do shell script "mv $TMPDIR/tempfile." & ext & " " & fname
				if show then
					do shell script "qlmanage -p " & fname
					select file filename
				end if
			end tell
		end if
	end repeat
	display notification "Your files now all measure " & w & "×" & h & " pixels." with title "Maximizing complete" subtitle "Processing is complete." sound name "default"
end open

on getDims(filename)
	tell application "Image Events"
		try
			set i to open filename
			set d to the dimensions of i & (the file type of i as string)
		on error errMsg number errNum
			-- Image Events for some reason can't get info on all images, so fall back to slower IM
			set d to the words of (do shell script "/usr/local/bin/identify -format \"%w, %h, %m\" " & POSIX path of fname)
		end try
	end tell
	return d
end getDims

use framework "Foundation"
use framework "AppKit"
on modifierKeysPressed()
	set modifierKeysDOWN to {command_down:false, option_down:false, control_down:false, shift_down:false}
	
	set |âŒ˜| to current application
	set currentModifiers to |âŒ˜|'s class "NSEvent"'s modifierFlags()
	
	tell modifierKeysDOWN
		set its option_down to (currentModifiers div (get |âŒ˜|'s NSAlternateKeyMask) mod 2 is 1)
		set its command_down to (currentModifiers div (get |âŒ˜|'s NSCommandKeyMask) mod 2 is 1)
		set its shift_down to (currentModifiers div (get |âŒ˜|'s NSShiftKeyMask) mod 2 is 1)
		set its control_down to (currentModifiers div (get |âŒ˜|'s NSControlKeyMask) mod 2 is 1)
	end tell
	
	return modifierKeysDOWN
end modifierKeysPressed

modifierKeysPressed()
