-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks

on open of finderObjects
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	repeat with filename in (finderObjects)
		set watermark to false
		set highlight to false
		set wrning to ""
		set somethingDone to false
		set myDocs to POSIX path of (path to documents folder) & "github/local/scripts/"
		# Make sure the file is a PDF, based on file info
		set fname to the POSIX path of filename
		set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
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
				set options to options & "-dFILTERTEXT "
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
		
		-- Handle watermarks first
		if watermark then
			set waterreply to (display dialog "Watermark removal can remove any instance of the text you enter, whether or not it appears as a proper watermark." with title "Warning" with icon caution default answer "Enter watermark text")
			set watermarkText to the text returned of waterreply
			if watermarkText ­ "" then
				set newText to ""
				-- Create string of spaces to replace watermark, so qpdf doesn't complain about file length
				-- This won't always work
				repeat until (length of newText) = (length of watermarkText)
					set newText to newText & " "
				end repeat
				-- Clean up the search string a little for perl with a warning when there are spaces in it.
				set watermarkText to (do shell script "echo " & watermarkText & "| perl -pe 's/([\\/\\.])/\\\\\\1/g'")
				set l1 to length of watermarkText
				set watermarkText to (do shell script "echo " & quoted form of watermarkText & " | sed 's/ /.*?/g'")
				set l2 to length of watermarkText
				if l1 ­ l2 then display alert "Spaces!" as warning message "There appear to be some spaces in your search text. This can introduce errors."
				set wateroutputfile to tmpdir & dateString & "_uncompressed.pdf"
				try
					do shell script "/opt/homebrew/bin/qpdf --stream-data=uncompress " & quoted form of fname & " " & wateroutputfile
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
				if (options ­ " " or highlight) then
					set wateroutputfile to tmpdir & dateString & "_compressed.pdf"
					set fname to wateroutputfile
				else
					set wateroutputfile to (quoted form of outputFile)
				end if
				try
					do shell script "/opt/homebrew/bin/qpdf --compress-streams=y " & tmpdir & "nowatermark.pdf " & wateroutputfile
					set somethingDone to true
				on error errMsg number errNum
					beep
					display alert "Compression Problem " & errNum as warning message errMsg
					error number -128
				end try
			else if (options = " " and not highlight) then
				beep
				display alert "No changes" as informational message "No changes were specified for the file, so no new file was created."
				error number -128
			end if
		end if
		
		-- Now remove highlighting, if requested
		if highlight then
			set inputFile to fname
			if options ­ " " then
				set highlightoutputfile to tmpdir & dateString & "_nohighlights.pdf"
				set fname to highlightoutputfile
			else
				set highlightoutputfile to (quoted form of outputFile)
				-- Running gs with no filters will do some compression or something
				--set options to ""
			end if
			set hl to (do shell script "/opt/homebrew/bin/python3 " & myDocs & "pdf_annotate.py -q -a Remove  -i " & (quoted form of inputFile) & " -o " & highlightoutputfile)
			if character 1 of hl = "N" then --there were no annotations found, so the file wasn't changed
				display alert "No annotations" as informational message "There weren't any annotations found, so none was removed." giving up after 30
				set fname to inputFile
			else
				set somethingDone to true
			end if
		end if
		
		-- Now process filters, if any were requested
		if options ­ " " then
			do shell script "/opt/homebrew/bin/gs -o " & (quoted form of outputFile) & " -sDEVICE=pdfwrite " & options & " " & (quoted form of fname)
			set somethingDone to true
		end if
	end repeat
	
	-- Notify of completion
	if somethingDone then display notification ("Your PDF has been filtered.") with title "Filtering done" sound name "beep"
end open

use framework "Foundation"
use framework "AppKit"
