# Delete all the metadata from a PDF, trashing the original file
# Uses installed versions of binaries

on open fileList
	# Set temporary directory for workspace
	set tempdir to (do shell script "echo $TMPDIR")
	
	# Explicit paths to binaries
	set qpdf to "/usr/local/bin/qpdf"
	set exiftool to "/usr/local/bin/exiftool"
	
	# Go through files
	repeat with filename in fileList
		# Make sure the file is a PDF, based on extension
		tell application "Finder"
			set ext to (name extension of file filename) as string
			set originalfilesize to (the size of file filename) as integer
		end tell
		set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		if ext is not "pdf" then
			tell application "Finder" to display alert "Wrong file type" message "This does not appear to be a PDF file: " & return & return & (name of filename) & return & return & "Quitting."
			error number -128
		else
			
			set keepdata to false
			
			# Get info on the file
			set pfile to the quoted form of the POSIX path of filename
			set pname to the quoted form of (do shell script "basename " & pfile)
			
			# Ask whether to keep some of the metadata
			set metadata to (do shell script exiftool & " -title -author " & pfile)
			if metadata is not "" then
				set metadata to (do shell script "echo " & metadata & " | perl -pe 's/\\s+:\\s/: /g'")
				set metadata to return & return & metadata
			end if
			set reply to (display dialog pname & return & return & "Do you want to keep this title and author metadata?" & metadata with title "Keep metadata?" buttons {"Cancel", "No", "Yes"} default button 3)
			if button returned of reply = "Yes" then set keepdata to true
			
			# Delete the potential destination file & then run exiftool
			do shell script "[ -s " & tempdir & pname & " ] && rm " & tempdir & pname & " &2>/dev/null"
			do shell script exiftool & " -o " & tempdir & " -all='' " & pfile
			
			# Transfer the title and author tags over
			if keepdata then
				do shell script exiftool & " -tagsfromfile " & pfile & " -title -author " & tempdir & pname
			end if
			
			-- Move the original to the trash, so it can be recovered if necessary
			tell application "Finder" to delete file filename
			-- Linearize the file to make the erased exif metadata unrecoverable
			do shell script qpdf & " " & tempdir & pname & " --linearize -- " & pfile
			tell application "Finder" to set newfilesize to (the size of file filename) as integer
		end if
		
	end repeat
	
	-- Notify of completion
	display notification ("Finished deleting the metadata from your file. It is now " & ((newfilesize - originalfilesize) * 100 / originalfilesize as integer) & "% bigger.") with title "Metadata removed" sound name "beep"
	
end open