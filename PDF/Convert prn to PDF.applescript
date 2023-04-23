# Convert a prn file to a PDF via ghostscript

global exiftool

on open fileList
	
	# Set temporary directory for workspace
	set tempdir to (do shell script "echo $TMPDIR")
	
	# Explicit paths to binaries
	set gs to "/opt/homebrew/bin/gs "
	set gsOptions to " -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="
	
	set processedCount to 0
	
	# Go through files
	set itemCount to (count of items of fileList)
	repeat with filename in fileList
		
		# Make sure the file is a prn file, based on extension
		tell application "Finder"
			set fname to name of filename
			set ext to (name extension of file filename) as string
		end tell
		set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
		if ext is "prn" then
			
			set keepdataSwitch to ""
			
			# Get info on the file
			set pfile to the quoted form of the POSIX path of filename
			set pPath to (do shell script "dirname " & pfile)
			set pname to (do shell script "basename " & pfile)
			set pbase to (do shell script "filename=" & quoted form of pname & "; echo ${filename%.*}")
			set outputFile to quoted form of (pPath & "/" & pbase & ".pdf")
			
			do shell script gs & gsOptions & outputFile & space & pfile
			set processedCount to processedCount + 1
		end if
		
	end repeat
	
	
	-- Notify of completion
	if processedCount = 1 then
		display notification ("Finished processing your file.") with title "PDF created" sound name "beep"
	else if processedCount > 1 then
		display notification "Finished processing " & processedCount & " files." with title "PDF created" sound name "beep"
	else
		display notification "Finished processing your files. None of them were changed." with title "All done!" sound name "beep"
	end if
	
end open

