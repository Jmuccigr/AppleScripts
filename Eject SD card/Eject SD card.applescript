-- Quick script to eject volume that is MS-DOS format, smaller than 64GB and ejectable, that is, it's an SD card for a camera.
-- By John Muccigrosso
-- v. 0.3

set targetDisk to {}

tell application "Finder"
	set targetDisk to every disk whose capacity < 6.4E+10 and ejectable is true and format is MSDOS format
	if targetDisk = {} then
		display alert "No such volume is mounted." giving up after 30
	else
		try
			repeat with aDisk in targetDisk
				set diskName to (name of aDisk as string)
				eject aDisk
				display notification "Disk " & diskName & " ejected successfully." as string sound name "chime"
			end repeat
		on error errStr number errorNumber
			display alert "Error " message errorNumber & ": " & return & errStr
		end try
	end if
end tell
