-- Filter PDF files using ghostscript
-- Esp. helpful for removing bad OCR text or watermarks

on open of finderObjects
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set fileList to ""
	-- Save new file in same dir as original with unique name
	set firstFile to (item 1 of finderObjects)
	tell application "Finder"
		set l to length of (name of file firstFile as string)
		set fname to dateString & "_" & characters 1 thru (l - 4) of ((name of file firstFile) as string)
		if length of fname > 251 then set fname to characters 1 thru 251 of fname
	end tell
	repeat with filename in (finderObjects)
		set fileList to fileList & quoted form of (POSIX path of filename) & " "
	end repeat
	
	-- Get paper size for output
	set options to " "
	try
		set outputSize to (items of (choose from list {"US letter", "US letter wide", "A4", "A4 wide"} with prompt "What size do you want the output to be?" with title "Choose page size" default items "US letter"))
		set outputSize to outputSize as string
		if outputSize contains "A4" then
			set outputSizeString to "A4"
		else
			set outputSizeString to "letter"
		end if
		if outputSize contains "wide" then
			set outputSizeString to outputSizeString & "^T"
		end if
	on error num
		error number -128
	end try
	
	# Get info on the file to combine for path and name
	set pfile to the POSIX path of filename
	set outputFile to (do shell script "dirname " & quoted form of pfile) & "/" & fname & "pdf"
	
	-- Now process files
	do shell script ("/usr/local/bin/img2pdf -o " & (quoted form of outputFile) & " -S " & outputSizeString & " " & fileList)
	
	-- Notify of completion
	display notification ("Your PDF has been created.") with title "PDF done" sound name "beep"
end open

use framework "Foundation"
use framework "AppKit"
