# Delete all the metadata from a PDF, trashing the original file
# Uses installed versions of exiftool & python script

global exiftool

on open fileList
	
	# Set temporary directory for workspace
	set tempdir to (do shell script "echo $TMPDIR")
	
	# Explicit paths to binaries
	set exiftool to "/opt/homebrew/bin/exiftool -q -q "
	
	# Create log record and log file name
	set logData to ""
	set pythonPath to (POSIX path of (path to documents folder as string)) & "github/local/scripts/"
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
			set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		end tell
		set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		if ext is not "pdf" then
			set logData to logData & ((filename) as string) & ": does not appear to be a PDF file. Skipping." & return
		else
			
			set keepdataSwitch to ""
			
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
					if button returned of reply = "Yes" then set keepdataSwitch to " -k "
				end if
				
				# Delete the potential destination file & then run exiftool
				try
					do shell script pythonPath & "pdf_remove_metadata.py " & keepdataSwitch & pfile & " " & tempdir & pname
				on error errMsg number errNum
					display alert "Problem with python script" message errNum & ": " & errMsg
					quit
				end try
				
				-- Move the original to the trash, so it can be recovered if necessary
				tell application "Finder" to delete file filename
				do shell script "mv " & tempdir & pname & " " & pfile
				if itemCount > 1 then
					set logData to logData & ((filename) as string) & ": deleted the metadata." & return
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
		display notification ("Finished deleting the metadata from your file.") with title "Metadata removed" sound name "beep"
	else if processedCount > 1 then
		display notification "Finished deleting the metadata from " & processedCount & " files. Log file is in your Documents folder." with title "Metadata removed" sound name "beep"
	else
		display notification "Finished processing your files. None of them were changed. Log file is in your Documents folder." with title "All done!" sound name "beep"
	end if
	
end open

on checkPDF(fn)
	try
		set xmp to (do shell script exiftool & "-q -q -b -xmp " & fn & " | xmllint -pretty 1 - | wc -l") as integer
	on error errMsg number errNum
		display dialog errNum & ": " & errMsg as string
		set xmp to 7
	end try
	set exif to (do shell script exiftool & fn)
	if ((count of paragraphs of exif) = 16 and (xmp = 7)) then
		return "does not appear to have extra metadata."
	else
		return ""
	end if
end checkPDF