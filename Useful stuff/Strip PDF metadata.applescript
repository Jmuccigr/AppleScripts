# Delete all the metadata from a PDF, trashing the original file
# Uses installed versions of binaries

global exiftool

on open fileList
	
	# Set temporary directory for workspace
	set tempdir to (do shell script "echo $TMPDIR")
	
	# Explicit paths to binaries
	set qpdf to "/usr/local/bin/qpdf "
	set exiftool to "/usr/local/bin/exiftool -q -q "
	
	# Create log record and log file name
	set logData to ""
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set logfile to (path to documents folder) & "PDF_metadata_" & dateString & ".txt" as string
	
	set processedCount to 0
	
	# Go through files
	set itemCount to (count of items of fileList)
	repeat with filename in fileList
		# Make sure the file is a PDF, based on extension
		tell application "Finder"
			set fname to name of filename
			set ext to (name extension of file filename) as string
			set originalfilesize to (the size of file filename) as integer
			set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		end tell
		set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		if ext is not "pdf" then
			set logData to logData & ((filename) as string) & ": does not appear to be a PDF file. Skipping." & return
		else
			
			set keepdata to false
			
			# Get info on the file
			set pfile to the quoted form of the POSIX path of filename
			set pname to the quoted form of (do shell script "basename " & pfile)
			
			set checkLog to my checkPDF(pfile)
			
			if checkLog is "" then
				# Ask whether to keep some of the metadata
				set metadata to (do shell script exiftool & " -title -author " & pfile)
				if metadata is not "" then
					set metadata to (do shell script "echo " & metadata & " | perl -pe 's/\\s+:\\s/: /g'")
					set metadata to return & return & metadata
					set reply to (display dialog pname & return & return & "Do you want to keep this title and author metadata?" & metadata with title "Keep metadata?" buttons {"Cancel", "No", "Yes"} default button 3)
					if button returned of reply = "Yes" then set keepdata to true
				end if
				
				# Delete the potential destination file & then run exiftool
				do shell script "[ -s " & tempdir & pname & " ] && rm " & tempdir & pname & " &2>/dev/null"
				try
					do shell script exiftool & " -o " & tempdir & " -all='' " & pfile
				end try
				
				# Transfer the title and author tags over
				if keepdata then
					do shell script exiftool & " -tagsfromfile " & pfile & " -title -author " & tempdir & pname
				end if
				
				-- Move the original to the trash, so it can be recovered if necessary
				tell application "Finder" to delete file filename
				-- Linearize the file to make the erased exif metadata unrecoverable
				do shell script qpdf & " " & tempdir & pname & " --linearize -- " & pfile
				tell application "Finder" to set newfilesize to (the size of file filename) as integer
				if itemCount > 1 then
					set logData to logData & ((filename) as string) & ": deleted the metadata. It is now " & ((newfilesize - originalfilesize) * 100 / originalfilesize as integer) & "% bigger." & return
				end if
				set processedCount to processedCount + 1
			else
				set logData to logData & ((filename) as string) & ": " & checkLog & " Skipping." & return
			end if
		end if
		
	end repeat
	
	# Write log to file
	if logData is not "" then
		set theOpenedFile to open for access file logfile with write permission
		write logData to theOpenedFile
		close access theOpenedFile
	end if
	
	-- Notify of completion
	if processedCount = 1 then
		display notification ("Finished deleting the metadata from your file. It is now " & ((newfilesize - originalfilesize) * 100 / originalfilesize as integer) & "% bigger.") with title "Metadata removed" sound name "beep"
	else if processedCount > 1 then
		display notification "Finished deleting the metadata from " & processedCount & " files. Log file is in your Documents folder." with title "Metadata removed" sound name "beep"
	else
		display notification "Finished processing your files. None of them were changed. Log file is in your Documents folder." with title "All done!" sound name "beep"
	end if
	
end open

on checkPDF(fn)
	set exif to (do shell script exiftool & fn)
	if (do shell script exiftool & " -Warning " & fn) is not "" then
		return "exiftool has a warning for this file."
	else if (count of paragraphs of exif) = 14 then
		return "does not appear to have extra metadata."
	else
		return ""
	end if
end checkPDF