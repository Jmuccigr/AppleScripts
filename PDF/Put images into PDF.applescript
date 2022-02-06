-- Put images into a single PDF

on open of finderObjects
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set fileList to ""
	set options to " "
	set defaultBorder to 0
	-- Save new file in same dir as original with unique name
	set firstFile to (item 1 of finderObjects)
	tell application "Finder"
		set l to length of (name of file firstFile as string)
		set extLength to the number of characters of (name extension of file firstFile as string)
		set fname to dateString & "_" & characters 1 thru (l - extLength - 1) of ((name of file firstFile) as string)
		if length of fname > 251 then set fname to characters 1 thru 251 of fname
	end tell
	repeat with fileName in (finderObjects)
		set fileList to fileList & quoted form of (POSIX path of fileName) & " "
	end repeat
	
	-- Get paper size for output
	try
		set outputSize to (items of (choose from list {"US letter", "US letter wide", "A4", "A4 wide", "Custom..."} with prompt "What size do you want the output to be?" with title "Choose page size" default items "US letter"))
		set outputSize to outputSize as string
		if outputSize = "Custom..." then
			set reply to (display dialog "What size do you want the output to be? You must enter a correctly formatted string including units (mm, cm, in) and no spaces:" with title "Enter page size" default answer "30cmx60cm")
			set outputSizeString to text returned of reply
		else
			if outputSize contains "A4" then
				set outputSizeString to "A4"
			else
				set outputSizeString to "letter"
			end if
			if outputSize contains "wide" then
				set outputSizeString to outputSizeString & "^T"
			end if
		end if
	on error num
		error number -128
	end try
	
	-- Get border size
	set borderSize to 999
	try
		repeat until borderSize < 10
			try
				set reply to (display dialog "Enter any border in cm's:" with title "Enter border size" default answer defaultBorder)
				set borderSize to text returned of reply as number
			on error errMsg number errNum
				if errNum = -128 then quit
				set borderSize to 999
				display alert "Numbers only" message "You need to enter a reasonable number here. Leave 0 for no borders."
			end try
		end repeat
	end try
	if borderSize < 999 then set options to " --border " & borderSize & "cm "
	
	# Get info on the file to combine for path and name
	set pfile to the POSIX path of fileName
	set outputFile to (do shell script "dirname " & quoted form of pfile) & "/" & fname & ".pdf"
	
	-- Now process files
	do shell script ("/usr/local/bin/img2pdf -o " & (quoted form of outputFile) & " -S " & outputSizeString & options & fileList)
	
	-- Notify of completion
	display notification ("Your PDF has been created.") with title "PDF done" sound name "beep"
end open

use framework "Foundation"
use framework "AppKit"
