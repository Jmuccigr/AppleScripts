# An app to correctly label the pages of a JSTOR PDF.
# It labels the first page "Cover" and then numbers rest.
# JSTOR does an awful job with page numbering (labels in PDF-speak).
# This script fixes that for basic cases, which are the majority.
# This assumes that the usual JSTOR thing is going on:
#    - the first page is the cover, but numbered anyway
#    - the actual content starts on the second page
#    - the page numbers are Arabic numerals and sequential
# For more complex page numbering, use my other PDF numbering script
# The script needs qpdf installed somewhere on your system.

on open of finderObjects
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
	
	# Initialize a variable
	try
		set qpdfPath to (do shell script "which qpdf")
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "No qpdf?" message "Couldn't find qpdf: " & return & errMsg
		error number -128
	end try
	
	try
		
		# Get starting-page number
		set pageReply to (display dialog "Enter the starting page number:" with title "Start Page" with icon note default answer "1")
		set startPage to the text returned of pageReply as integer
		
		# Create a PDF with numbered pages for merging
		do shell script (qpdfPath & " --replace-input " & pfile & " --set-page-labels 1://\"Cover\" 2:D/" & startPage & " --")
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "Error!" message "Something went wrong: " & return & errMsg
		error number -128
	end try
	
	-- Notify of completion
	if theResult is "" then
		display notification ("Your JSTOR PDF now has correct page numbers.") with title "Numbering done" sound name "beep"
	else
		display alert "Problem!" message "There was a problem creating the PDF:" & return & return * theResult
	end if
	
end open