# An app to redo the OCR of a PDF.
# This was designed to handle JSTOR files which often
# have poor OCR and a cover page, so it redoes the OCR and
# gives the option to restore the first X pages.
# The script needs qpdf and ocrmypdf installed somewhere on your system.

on open of finderObjects
	
	
	# Initialize app variables
	set startPage to 0
	set psm to 3
	set username to (do shell script "echo $USER")
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	# Check for binaries
	try
		set qpdfPath to (do shell script "which qpdf")
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "No qpdf?" message "Couldn't find qpdf: " & return & errMsg
		error number -128
	end try
	try
		set ocrPath to (do shell script "which ocrmypdf")
		set ocrPath to "env TESSDATA_PREFIX=/Users/" & username & "/Documents/tessdata/ " & ocrPath
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "No ocrmypdf?" message "Couldn't find ocrmypdf: " & return & errMsg
		error number -128
	end try
	
	# Get only the first of multiple items
	set fname to item 1 of finderObjects
	# Make sure the file is a PDF, based on file info
	set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
	if characters 1 thru 15 of ftype as string is not "application/pdf" then
		display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
		error number -128
	end if
	
	# Get some info on the file
	tell application "Finder" to set fpath to container of file fname
	set pfile to quoted form of the POSIX path of fname
	set tmpdir to (do shell script "echo $TMPDIR")
	
	try
		# Get starting-page number and OCR language(s) and page segmentation mode
		repeat until startPage > 0
			set pageReply to (display dialog "Enter the starting page number for OCR:" with title "Start Page" with icon note default answer "2")
			set startPage to (the text returned of pageReply) as integer
		end repeat
		set langReply to (display dialog "Enter the language code:" with title "OCR Language" with icon note default answer "eng")
		set lang to the text returned of langReply
		set lang to (do shell script "echo " & lang & " | perl -pe 's/[^a-z+]//g'")
		if lang = "" then set lang to "eng"
		set psmReply to (display dialog "Does your document have more than one column per page?" with title "Column count" with icon note buttons {"Yes", "No", "Cancel"} default button 2)
		if button returned of psmReply = "yes" then set psm to 1
		
		
		# Copy the file to the tmpdir, removing the irrelevant pages if needed, to save a little time in OCR
		try
			if startPage is not 1 then
				do shell script (qpdfPath & space & pfile & " --pages . " & startPage & "-z -- " & tmpdir & dateString & ".pdf")
			else
				do shell script "cp " & pfile & " $TMPDIR"
			end if
		on error errMsg number errNum
			if errMsg is not "User canceled." then
				if errMsg contains "WARNING" then
					display alert "Problem" message "We'll carry on, but there was a potential problem with the temporary PDF: " & return & errMsg
				else
					display alert "Problem" message "There was a problem creating the temporary PDF: " & return & errMsg
					error number -128
				end if
			end if
		end try
		
		# Do the OCR
		display notification ("Now doing OCR...") with title "OCR" sound name "beep"
		set theResult to (do shell script (ocrPath & " -l " & lang & " --tesseract-pagesegmode " & psm & " --redo-ocr " & pfile & space & tmpdir & dateString & ".pdf"))
		
		# Restore pages if the whole file was not OCR'ed
		try
			if startPage is not 1 then
				set theResult to (do shell script (qpdfPath & " --replace-input " & tmpdir & dateString & ".pdf" & " --pages " & pfile & space & "1-" & (startPage - 1) & " . " & startPage & "-z --"))
			end if
		on error errMsg number errNum
			if errMsg contains "WARNING" then
				display alert "Problem" message "We'll carry on, but there was a potential problem with the final PDF: " & return & errMsg
			else
				display alert "Problem" message "There was a problem creating the final PDF: " & return & errMsg
				error number -128
			end if
		end try
		tell application "Finder" to delete file fname
		do shell script "mv " & tmpdir & dateString & ".pdf " & pfile
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "Error!" message "Something went wrong: " & return & errMsg
		error number -128
	end try
	
	-- Notify of completion
	if theResult is "" then
		display notification "Your PDF now has been OCRed." with title "OCR done" sound name "beep"
	else
		display alert "Problem!" message "There was a problem OCRing the PDF:" & return & return * theResult
	end if
	
end open
