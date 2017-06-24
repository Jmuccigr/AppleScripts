-- Quick script to sync SD card for a camera with on-computer script folder
-- By John Muccigrosso
-- v. 0.2

set targetDisk to {}

tell application "Finder"
	set targetDisk to every disk whose size < 6.4E+10 and ejectable is true and format is MSDOS format
	if targetDisk = {} then
		display alert "No such volume is mounted." giving up after 30
	else
		try
			display notification "Sync'ing scripts..."
			set myDocs to POSIX path of (path to documents folder)
			repeat with aDisk in targetDisk
				set hdPath to (myDocs & "CHDK/CHDK scripts/")
				set ssdPath to ("/Volumes/" & name of aDisk & "/CHDK/SCRIPTS/")
				if (exists POSIX file hdPath as alias) and (exists POSIX file ssdPath as alias) then -- Not clear to me why we don't need the quoted form
					-- Sync them up, hard drive to SD card first
					do shell script "rsync -vau " & quoted form of hdPath & " " & quoted form of ssdPath & " 1>/dev/null"
					do shell script "rsync -vau " & quoted form of ssdPath & " " & quoted form of hdPath & " 1>/dev/null"
					display notification "Sync successful!" sound name "chime"
				end if
			end repeat
		on error errStr number errorNumber
			display alert "Error " & errorNumber message errStr
		end try
	end if
end tell
