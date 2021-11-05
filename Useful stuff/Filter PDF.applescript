-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks

on open of finderObjects
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	repeat with filename in (finderObjects)
		set watermark to false
		set wrning to ""
		# Make sure the file is a PDF, based on file info
		set fname to the POSIX path of filename
		set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
		if characters 1 thru 15 of ftype as string ≠ "application/pdf" then
			display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
			quit
		end if

		-- Get filter to apply
		set options to " "
		try
			set reply to (items of (choose from list {"Watermark text", "Text", "Raster Images", "Vector Images"} with prompt "What do you want to try to remove?" with title "Choose filter type" default items "Vector Images" with multiple selections allowed))
		on error num
			error number -128
		end try
		repeat with filter in reply
			set filter to (filter as string)
			if (filter is "Watermark text") then set watermark to true
			if (filter is "Text") then
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

		-- Handle watermarks first
		if watermark then
			set waterreply to (display dialog "Watermark removal can remove any instance of the text you enter, whether or not it appears as a proper watermark." with title "Warning" with icon caution default answer "Enter watermark text")
			set watermarkText to the text returned of waterreply
			set watermarkText to (do shell script "echo " & quoted form of watermarkText & " | sed 's/ /.*?/g'")
			if watermarkText ≠ "" then
				set newText to ""
				-- Create string of spaces to replace watermark, so qpdf doesn't complain about file length
				repeat until (length of newText) = (length of watermarkText)
					set newText to newText & " "
				end repeat
				set tmpdir to (do shell script "echo $TMPDIR")
				set wateroutputfile to tmpdir & dateString & "_uncompressed.pdf"
				try
					do shell script "/usr/local/bin/qpdf --stream-data=uncompress " & quoted form of fname & " " & wateroutputfile
				on error errMsg number errNum
					if errMsg contains "Warning" then set wrning to (("Uncompression Warning" & return & errMsg) as string)
				end try
				do shell script "perl -pe 's/\\(.*?" & watermarkText & ".*?\\)/" & "(" & newText & ")/' " & wateroutputfile & " > " & tmpdir & "nowatermark.pdf"
				if options ≠ " " then
					set wateroutputfile to "$TMPDIR/" & dateString & "_compressed.pdf"
					set fname to wateroutputfile
				else
					set wateroutputfile to (quoted form of outputFile)
				end if
				try
					do shell script "/usr/local/bin/qpdf --compress-streams=y " & tmpdir & "nowatermark.pdf -- " & wateroutputfile
				on error errMsg number errNum
					if errMsg does not contain "Warning" then display alert "Compression Problem" message errMsg
				end try
			else if options = " " then
				beep
				display alert "No changes" message "No changes were specified for the file, so no new file was created."
				error number -128
			end if
		end if

		-- Now process filters, if any were requested
		if options ≠ " " then
			do shell script "/usr/local/bin/gs -o " & (quoted form of outputFile) & " -sDEVICE=pdfwrite " & options & " " & (quoted form of fname)
		end if
	end repeat

	-- Notify of completion
	display notification ("Your PDF has been filtered.") with title "Filtering done" sound name "beep"
	if wrning ≠ "" then display alert "Warning" message wrning

end open

use framework "Foundation"
use framework "AppKit"
