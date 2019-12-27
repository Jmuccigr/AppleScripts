-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks

on open of finderObjects
	repeat with filename in (finderObjects)
		# Make sure the file is a PDF, based on file info
		set fname to the POSIX path of filename
		set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
		if characters 1 thru 15 of ftype as string ­ "application/pdf" then
			display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
			quit
		end if
		
		-- Get filter to apply
		set options to " "
		set reply to (items of (choose from list {"Text", "Raster Images", "Vector Images"} with prompt "What do you want to try to remove?" with title "Choose filter type" default items "Vector Images" with multiple selections allowed))
		repeat with filter in reply
			set filter to (filter as string)
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
		
		do shell script "$(which gs) -o " & outputFile & " -sDEVICE=pdfwrite " & options & " " & fname
	end repeat
end open

use framework "Foundation"
use framework "AppKit"
