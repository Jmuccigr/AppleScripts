-- Set all images to the size of the largest in the group using imagemagick
-- If the shift key is down, the quicklook behavior is reversed

on open finderObjects
	--if shift_down of modifierKeysPressed() then set show to not show
	set tiff to " -define tiff:preserve-compression=true "
	set dimList to {}
	set ct to (the count of finderObjects)
	if ct = 1 then
		display alert "No point!" message "This process requires more than one file to work on."
		error number -128
	end if
	(*
	if ct < 4 then
		set show to true
	else
		set show to false
	end if
*)
	set w to 0
	set h to 0
	set changed to false
	-- First loop through to get the dimensions
	repeat with filename in (finderObjects)
		set {newW, newH} to getDims(filename)
		-- Save the dimensions, so we don't have to process them again later
		set the end of dimList to {newW, newH}
		if not changed then
			if (newW ≠ w or newH ≠ h) and w ≠ 0 then set changed to true
		end if
		if (newW > w) then set w to newW
		if (newH > h) then set h to newH
	end repeat
	if not changed then
		display alert "No need!" message "All of these files are already the same size. Exiting..."
		error number -128
	end if
	-- Now loop through to change the files
	set i to 0
	repeat with filename in (finderObjects)
		set i to i + 1
		set extraW to 0
		set extraH to 0
		set extra to ""
		set fname to quoted form of POSIX path of filename
		tell application "Finder" to set ext to the name extension of filename
		set {docW, docH} to item i of dimList
		if ((docW & " " & docH) as string ≠ (w & " " & h) as string) then
			set addW to (w - docW) / 2 as integer
			if docW + 2 * addW ≠ w then set extraW to 1
			set addH to (h - docH) / 2 as integer
			if docH + 2 * addH ≠ h then set extraH to 1
			if extraH + extraW > 0 then
				set extra to " -background white -gravity west -splice " & extraW & "x0 -gravity south -splice 0x" & extraH
			end if
			do shell script ("/opt/homebrew/bin/magick " & fname & tiff & " -bordercolor white -border " & addW & "x0 -border 0x" & addH & extra & " $TMPDIR/tempfile." & ext)
			tell application "Finder"
				delete file filename
				do shell script "mv $TMPDIR/tempfile." & ext & " " & fname
				(*
				if show then
					do shell script "qlmanage -p " & fname
					select file filename
				end if
*)
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
			-- Always close the file or Image Events will remember its former state
			close i
		on error errMsg number errNum
			-- Image Events for some reason can't get info on all images, so fall back to slower IM
			close i
			set d to the words of (do shell script "/opt/homebrew/bin/identify -format \"%w, %h, %m\" " & POSIX path of fname)
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
