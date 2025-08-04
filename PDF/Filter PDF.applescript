-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks
global tmpdir, dateString, home, myDocs, somethingDone

on open of finderObjects
	set home to (do shell script "whoami")
	set myDocs to POSIX path of (path to documents folder) & "github/local/scripts/"
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set watermark to false
	set highlight to false
	set txt to false
	
	repeat with filename in (finderObjects)
		set somethingDone to false
		# Make sure the file is a PDF, based on file info
		set inputname to the POSIX path of filename
		set ftype to (do shell script "file -bI " & quoted form of (POSIX path of inputname))
		if characters 1 thru 15 of ftype as string ­ "application/pdf" then
			display alert "Wrong file type" as critical message "This does not appear to be a PDF file. Quitting."
			quit
		end if
		
		-- Get filter to apply
		set options to " "
		try
			set reply to (items of (choose from list {"Watermark text", "Text", "Raster Images", "Vector Images", "Highlighting"} with prompt "What do you want to try to remove?" with title "Choose filter type" default items "Vector Images" with multiple selections allowed))
		on error num
			error number -128
		end try
		repeat with filter in reply
			set filter to (filter as string)
			if (filter is "Watermark text") then
				set watermark to true
			else if (filter is "Highlighting") then
				set highlight to true
			else if (filter is "Text") then
				set txt to true
			else if filter = "Raster Images" then
				set options to options & "-dFILTERIMAGE "
			else if filter = "Vector Images" then
				set options to options & "-dFILTERVECTOR "
			end if
		end repeat
		
		-- Save new file in same dir as original with unique name
		tell application "Finder"
			set l to length of (name of file filename as string)
			set fnameString to dateString & "_" & characters 1 thru (l - 4) of ((name of file filename) as string)
			if length of fnameString > 251 then set fnameString to characters 1 thru 251 of fnameString
		end tell
		# Get info on the file to combine for path and name
		set pfile to the POSIX path of filename
		set outputFile to (do shell script "dirname " & quoted form of pfile) & "/" & fnameString & ".pdf"
		set tmpdir to (do shell script "echo $TMPDIR")
		
		if watermark then
			set waterreply to (display dialog "Watermark removal can remove any instance of the text you enter, whether or not it appears as a proper watermark." with title "Warning" with icon caution default answer "Enter watermark text")
			set watermarkText to the text returned of waterreply
			if watermarkText ­ "" then
				set inputname to my removeWatermark(inputname, watermarkText)
			end if
		end if
		
		if txt then set inputname to my removeTxt(inputname)
		if highlight then set inputname to my removeHighlighting(inputname)
		if options ­ " " then set inputname to my processFilters(inputname, options)
		
		-- Notify of completion
		if somethingDone then
			do shell script "mv " & quoted form of inputname & space & quoted form of outputFile
			display notification ("Your PDF has been filtered.") with title "Filtering done" sound name "beep"
		else
			display notification ("Nothing was done to your PDF.") with title "Done" sound name "beep"
		end if
	end repeat
end open

-- Handle watermarks first
on removeWatermark(inputfile, watermarkText)
	-- Create string of spaces to replace watermark, so qpdf doesn't complain about file length
	-- This won't always work
	-- Ask first
	set reply to (the button returned of (display dialog "Do you want to replace the text with blanks or just delete it?" buttons {"Cancel", "Delete", "Replace"} default button 3 cancel button 1))
	if reply = "Replace" then
		set newText to ""
		set newChar to " "
		repeat until (length of newText) = (length of watermarkText)
			set newText to newText & newChar
		end repeat
	else
		set newText to ""
	end if
	-- Clean up the search string a little for perl with a warning when there are spaces in it.
	set watermarkText to (do shell script "echo " & quoted form of watermarkText & "| perl -pe 's/([\\/\\.])/\\\\\\1/g'")
	set l1 to length of watermarkText
	set watermarkText to (do shell script "echo " & quoted form of watermarkText & " | sed 's/ /.*?/g'")
	set l2 to length of watermarkText
	if l1 ­ l2 then display alert "Spaces!" as warning message "There appear to be some spaces in your search text. This can introduce errors."
	set wateroutputfile to tmpdir & dateString & "_uncompressed.pdf"
	try
		do shell script "/opt/homebrew/bin/qpdf --stream-data=uncompress --decode-level=all " & quoted form of inputfile & " " & wateroutputfile
	on error errMsg number errNum
		beep
		display alert "Uncompression Warning " & errNum as warning message errMsg
		error number -128
	end try
	try
		do shell script "perl -pe 's/(?<!\\/Title )\\(([^(]*?)" & watermarkText & "(.*?)\\)/" & "(\\1" & newText & "\\2)/' " & wateroutputfile & " > " & tmpdir & "nowatermark.pdf"
	on error errMsg number errNum
		beep
		display alert "perl Warning " & errNum as warning message errMsg
		error number -128
	end try
	try
		do shell script "/opt/homebrew/bin/qpdf --compress-streams=y --decode-level=all " & tmpdir & "nowatermark.pdf " & wateroutputfile
		set somethingDone to true
	on error errMsg number errNum
		try
			do shell script "/opt/homebrew/bin/qpdf --compress-streams=n " & tmpdir & "nowatermark.pdf " & wateroutputfile
			set somethingDone to true
			display alert "No compression" message "qpdf had a problem compressing the file, so it was left uncompressed."
		on error errMsg number errNum
			beep
			if errMsg contains "operation succeeded" then
				set somethingDone to true
				set errMsg to "Operation succeeded with some issues" & return & return & errMsg
			end if
			set errMsg to items 1 thru 300 of errMsg as string
			display alert "Compression Problem " & errNum as warning message errMsg
		end try
	end try
	return wateroutputfile
end removeWatermark

on removeTxt(inputfile) -- Now remove text, if requested. Using python script to avoid gs increasing file size.
	set txtoutputfile to tmpdir & dateString & "_notext.pdf"
	-- Running gs with no filters will do some compression or something
	--set options to ""
	do shell script "source /Users/" & home & "/.venv/bin/activate; " & myDocs & "remove_PDF_text.py " & (quoted form of inputfile) & " " & (quoted form of txtoutputfile)
	set somethingDone to true
	return txtoutputfile
end removeTxt

on removeHighlighting(inputfile)
	-- Now remove highlighting, if requested
	set highlightoutputfile to tmpdir & dateString & "_nohighlights.pdf"
	-- Running gs with no filters will do some compression or something
	--set options to ""
	do shell script "/opt/homebrew/bin/gs -o " & (quoted form of highlightoutputfile) & " -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -c \"/PreserveAnnotTypes [] def\" -c \"/ShowAnnotTypes [] def\" -f " & (quoted form of inputfile)
	set somethingDone to true
	return highlightoutputfile
end removeHighlighting

on processFilters(inputfile, options)
	-- Now process filters, if any were requested
	set filteredoutputfile to tmpdir & dateString & "_filtered.pdf"
	if options ­ " " then
		do shell script "/opt/homebrew/bin/gs -o " & (quoted form of filteredoutputfile) & " -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite " & options & " " & (quoted form of inputfile)
		set somethingDone to true
		return filteredoutputfile
	end if
end processFilters
