on open fname
	# Make sure the file is a docx, based on extension
	tell application "Finder"
		set ext to (name extension of file fname) as string
	end tell
	set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
	if ext is not "docx" then
		display alert "Wrong file type" message "This does not appear to be a new Word file. Quitting."
		quit
	end if
	
	# Create likely unique name for destination folder
	# System will create the new folder automatically
	tell application "Finder"
		set fnameString to characters 1 thru 15 of (((name of file fname) as string) & "              ") as string
		set fnameString to (do shell script "echo " & quoted form of fnameString & " | tr ' ' '_'")
	end tell
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/" & dateString & "_" & fnameString & "_images"
	
	# Extract files in the word/media directory into the same folder as the file.
	# Could check for image files, but haven't yet.
	do shell script "unzip -n -j -d " & quoted form of fpath & " " & quoted form of pfile & " word/media/*"
end open