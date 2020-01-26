-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks

on open of finderObjects
	repeat with filename in (finderObjects)
		set watermark to false
		# Make sure the file is a PDF, based on file info
		set fname to the POSIX path of filename
		set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
		if characters 1 thru 15 of ftype as string ­ "application/pdf" then
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
			set fnameString to characters 1 thru 15 of (((name of file filename) as string) & "              ") as string
			set fnameString to (do shell script "echo " & quoted form of fnameString & " | tr ' ' '_'")
		end tell
		set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
		# Get info on the file to combine for path and name
		set pfile to the POSIX path of filename
		set outputFile to (do shell script "dirname " & quoted form of pfile) & "/" & dateString & "_" & fnameString & ".pdf"
		
		-- Handle watermarks first
		if watermark then
			set waterreply to (display dialog "Watermark removal will remove any instance of the text you enter, whether or not it appears as a proper watermark." with title "Warning" with icon caution default answer "Enter watermark text")
			set watermarktext to the text returned of waterreply
			set tmpdir to (do shell script "echo $TMPDIR")
			do shell script "/usr/local/bin/pdftk " & quoted form of fname & " output " & tmpdir & "uncompressed.pdf" & " uncompress"
			do shell script "perl -pe 's/" & watermarktext & "//' " & tmpdir & "uncompressed.pdf > " & tmpdir & "nowatermark.pdf"
			if options ­ " " then
				set wateroutputfile to tmpdir & "compressed.pdf"
				set fname to wateroutputfile
			else
				set wateroutputfile to (quoted form of outputFile)
			end if
			do shell script "/usr/local/bin/pdftk " & tmpdir & "nowatermark.pdf output " & wateroutputfile & " compress"
		end if
		
		-- Now process filters, if any were requested
		if options ­ " " then
			do shell script "/usr/local/bin/gs -o " & (quoted form of outputFile) & " -sDEVICE=pdfwrite " & options & " " & (quoted form of fname)
		end if
	end repeat
	
	-- Notify of completion
	display notification ("Your PDF has been filtered.") with title "Filtering done" sound name "beep"
	
end open

use framework "Foundation"
use framework "AppKit"
