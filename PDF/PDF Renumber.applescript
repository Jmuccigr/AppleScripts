-- Renumber PDF files using qpdf

global dateString, myDocs

on open of finderObjects
	set myDocs to POSIX path of (path to documents folder) & "github/local/scripts/"
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set outputFile to ""
	set flag to ""
	
	set replace to (button returned of (display dialog "Do you want to replace the original file or create a new one?" with title "Replace?" buttons {"Cancel", "New", "Replace?"} default button 3))
	
	repeat with filename in (finderObjects)
		# Make sure the file is a PDF, based on file info
		set pfile to the quoted form of the POSIX path of filename
		set ftype to (do shell script "file -bI " & pfile)
		if characters 1 thru 15 of ftype as string ­ "application/pdf" then
			display alert "Wrong file type" as critical message "This does not appear to be a PDF file. Quitting."
			exit repeat
		else
			set cmd to ""
			set filedone to false
			set firstDone to false
			set range to "0"
		end if
		
		-- Save new file in same dir as original with unique name
		if replace = "New" then
			tell application "Finder"
				set fn to name of file filename as string
				set l to length of fn
				if length of fn > 231 then set fn to characters 1 thru 231 of fn
				set fnameString to fn & "_" & dateString
			end tell
			# Get info on the file to combine for path and name
			set outputFile to the quoted form of ((do shell script "dirname " & pfile) & "/" & fnameString & ".pdf")
		else
			set flag to " --replace-input "
		end if
		
		repeat until filedone
			try
				set reply to (choose from list {"Digits: 1 2 3", "ROMAN numerals: I II III", "roman numerals: i ii iii", "ALPHABETIC: A B C", "alphabetic: a b c", " (blank)"} with prompt "What kind of numbering?" with title "Choose number type" default items "Digits: 1 2 3" OK button name "OK" cancel button name "Cancel")
				if reply is false then error number -128
				set type to character 1 of item 1 of reply
				-- Use blank string for blank so a prefix can be added, if desired
				if type is " " then set type to ""
				-- Start the range at the next unused page and fall back to 2 in case r or z is used
				try
					set startPage to (range as integer) + 1
					set counter to (range as integer) + 1
				on error
					set startPage to 2
					set counter to 2
				end try
				set reply to (display dialog "Enter the starting page of this range using qpdf's style (number, z, r#)." with title "Select start page" default answer startPage)
				set range to word 1 of text returned of reply
				if (range = "1" and not firstDone) then
					set firstDone to true
				end if
				if not firstDone then
					display alert "Start page" message "The first start page has to be page 1. Choose the \"(blank)\" option if you don't want any page numbers at the start of the document."
				else
					-- Get the logical start number, but not if the blank option was chosen
					if type is not "" then
						set startNumber to text returned of (display dialog "Enter the starting number to label the range with. This must be a number. Default value is 1." with title "Select start number" default answer "")
						set startNumber to (do shell script "echo " & startNumber & " | sed 's/[^0-9]//g'")
					else
						set startNumber to ""
					end if
					-- Set the default button to "Done" after the first range
					set reply to (display dialog "Enter the text used to prefix each page number in this range." with title "Select prefix" default answer "" buttons {"Next", "Done", "Cancel"} default button (1 + (round ((counter - 0.5) / counter))))
					set prefix to quote & text returned of reply & quote
					if (startNumber is not "" or prefix is not quote & quote) then set startNumber to "/" & startNumber & "/" & prefix
					set cmd to cmd & range & ":" & type & startNumber & space
					if button returned of reply is "Done" then
						set filedone to true
					end if
				end if
			on error errMsg number errNum
				if errNum is not -128 then
					display alert "Error" message errNum & ": " & errMsg
				end if
				error number -128
			end try
			
		end repeat
		
		-- Process and save file
		try
			do shell script "$(which qpdf) " & flag & pfile & " --set-page-labels " & cmd & " -- " & outputFile
			display notification ("Your PDF has been re-numbered.") with title "Page numbering done" sound name "beep"
		on error errMsg number num
			if errMsg contains " succeeded with warnings" then
				display alert "Warning" message "qpdf had some issues with file " & pfile & return & num & ":" & errMsg
			else
				display alert "Error" message "Something went wrong with qpdf and file " & pfile & return & num & ":" & errMsg
			end if
		end try
		
	end repeat
	
end open
