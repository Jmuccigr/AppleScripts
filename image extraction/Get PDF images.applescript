on open fname
	# Make sure the file is a PDF, based on extension
	tell application "Finder"
		set ext to (name extension of file fname) as string
	end tell
	set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
	if ext is not "pdf" then
		display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
		quit
	end if
	
	# Set file types to be handled
	set filetypes to "  -png -tiff -j -jp2 -ccitt "
	
	# Use the version of the script embedded in the app
	set imagePath to quoted form of ((POSIX path of (path to me) as string) & "Contents/Resources/pdfimages")
	set infoPath to quoted form of ((POSIX path of (path to me) as string) & "Contents/Resources/pdfinfo")
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/"
	
	# Make sure there are images in the file
	set imageCount to (do shell script (imagePath & " -list " & quoted form of pfile & " | wc -l")) * 1 - 2
	if imageCount = 0 then
		display alert "No images!" message "Oops. This file has no images in it."
		quit
	end if
	
	# Get number of pages for input checking
	set pageCount to (do shell script infoPath & " " & quoted form of pfile & " | grep Pages | sed 's/Pages://'") as number
	
	# Get pages to process, making sure that they're valid pages for the document
	set fpage to (pageCount + 1)
	repeat until (fpage ² pageCount) and (fpage > 0)
		set fpage to text returned of (display dialog "There are " & pageCount & " pages in this PDF. What's the first page to extract images from?" default answer "1" with title "First Page") as number
		if fpage > pageCount or fpage < 1 then display alert "Invalid page number" message "First page must be a valid number."
	end repeat
	set lpage to 0
	repeat until (lpage ² pageCount) and (lpage ³ fpage)
		set lpage to text returned of (display dialog "There are " & pageCount & " pages in this PDF and you're starting on page " & fpage & ". What's the last page to extract images from?" default answer fpage with title "Last Page") as number
		if (lpage > pageCount) or (lpage < fpage) then display alert "Invalid page number" message "You must enter a valid page number."
	end repeat
	set outputname to text returned of (display dialog "What's the output file name?" default answer "output_" with title "Name of output images")
	do shell script (imagePath & filetypes & " -f " & fpage & " -l " & lpage & " " & quoted form of pfile & " " & quoted form of (fpath & outputname))
end open