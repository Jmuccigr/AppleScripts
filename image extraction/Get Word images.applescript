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
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/"
	
	# Extract files in the word/media directory into the same folder as the file.
	# Could check for image files, but haven't yet.
	do shell script "unzip -n -j -d " & fpath & " " & quoted form of pfile & " word/media/*"
end open