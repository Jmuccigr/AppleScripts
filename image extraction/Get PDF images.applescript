# Extract images from specific pages in a PDF, saving them to a new folder with the original file
# Uses homebrew installed versions of binaries

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
	set filetypes to " -png -tiff -j -jp2 -ccitt "
	
	# Explicit paths to binaries
	set imagePath to "/usr/local/bin/pdfimages"
	set infoPath to "/usr/local/bin/pdfinfo"
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/"
	
	# Make sure there are images in the file
	set imageCount to ((do shell script (imagePath & " -list " & quoted form of pfile & " | wc -l")) as integer) - 2
	if imageCount = 0 then
		display alert "No images!" message "Oops. This file has no images in it."
		quit
	end if
	
	# Get number of pages for input checking
	set pageCount to (do shell script infoPath & " " & quoted form of pfile & " | grep 'Pages:' | sed 's/Pages://'") as number
	
	# Get pages to process, making sure that they're valid pages for the document
	set fpage to (pageCount + 1)
	if pageCount ­ 1 then
		repeat until (fpage ² pageCount) and (fpage > 0)
			try
				set fpage to text returned of (display dialog "There are " & pageCount & " pages in this PDF. What's the first page to extract images from?" default answer "1" with title "First Page") as number
				if fpage > pageCount or fpage < 1 then display alert "Invalid page number" message "First page must be a valid number."
			on error errMsg number errNum
				if errNum = -1700 then
					display dialog "That's not a number!" with title "Use a number"
				else
					if errNum ­ -128 then
						display dialog errMsg with title errNum
					else
						error number -128
					end if
				end if
			end try
		end repeat
	else
		set fpage to 1
	end if
	# Don't ask about last page to process if the first page _is_ the last page of the document
	if fpage = pageCount then
		set lpage to pageCount
	else
		set lpage to 0
	end if
	repeat until (lpage ² pageCount) and (lpage ³ fpage)
		try
			set lpage to text returned of (display dialog "There are " & pageCount & " pages in this PDF and you're starting on page " & fpage & ". What's the last page to extract images from?" default answer fpage with title "Last Page") as number
			if (lpage > pageCount) or (lpage < fpage) then display alert "Invalid page number" message "You must enter a set of valid page numbers."
		on error errMsg number errNum
			if errNum = -1700 then
				display dialog "That's not a number!" with title "Use a number"
			else
				if errNum ­ -128 then
					display dialog errMsg with title errNum
				else
					error number -128
				end if
			end if
		end try
	end repeat
	set outputname to text returned of (display dialog "What's the output file name?" default answer "output_" with title "Name of output images")
	
	# Create likely unique name for destination folder
	tell application "Finder"
		set fnameString to characters 1 thru 15 of (((name of file fname) as string) & "              ") as string
		set fnameString to (do shell script "echo " & quoted form of fnameString & " | tr ' ' '_'")
	end tell
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	
	# Get info on the file & make destination folder
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/" & dateString & "_" & fnameString & "_images/"
	do shell script ("mkdir " & quoted form of fpath)
	
	do shell script (imagePath & filetypes & " -f " & fpage & " -l " & lpage & " -p " & quoted form of pfile & " " & quoted form of (fpath & outputname))
	
	-- Notify of completion
	display notification ("Finished extracting images from your file.") with title "Image extraction" sound name "beep"
	
end open