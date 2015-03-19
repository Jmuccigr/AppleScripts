-- A script to take the front document in MacDown and have pandoc process it.
-- Assumes that MacDown is the frontmost app, which can be ensured by putting the script in the Scripts folder for MacDown.

on run
	
	-- Some stuff to make it easier to debug this script
	tell application "Finder"
		set the visible of process "AppleScript Editor" to false
		tell application "MacDown" to activate
	end tell
	
	--Wrapping the whole thing in this tell to keep error messages in MacDown (not sure this is necessary)
	tell application "MacDown"
		-- Set some variables for use later on
		set validFile to false
		set hasext to false
		set fname to ""
		set fpath to ""
		-- For pandoc. Use single-quoted form of POSIX path
		set bibfile to "'/Users/john_muccigrosso/Documents/My Library.bib'"
		
		-- Create shell script for pandoc
		--	First have to reset PATH to use homebrew binaries; there are other approaches to this problem.
		set shcmd to "export PATH=/usr/local/bin:/usr/local/sbin:$PATH"
		--	Now add the pandoc switches. Note the quoted filepaths.
		set shcmd to shcmd & "; pandoc -s -S --bibliography=" & bibfile & " --latex-engine=xelatex --reference-odt='/Users/john_muccigrosso/Library/Application Support/LibreOffice/4/user/template/Butterick 11.ott' --reference-docx='/Users/john_muccigrosso/Library/Application Support/Microsoft/Office/User Templates/Normal.dotm'"
		
		-- Get info for frontmost window	in MacDown
		-- The first part won't ever work for MacDown because it doesn't do applescript.
		try
			tell application "MacDown" -- (path to frontmost application as text)
				set fpath to (path of document 1) as text
				set fname to (name of document 1) as text
			end tell
		on error
			try
				tell application "System Events" to tell (process 1 where frontmost is true)
					set fpath to value of attribute "AXDocument" of window 1
					set fname to value of attribute "AXTitle" of window 1
				end tell
				-- When the document hasn't been saved, fpath gets assigned "missing value" for which we create a special error.
				if fpath is missing value then
					display alert "Unsaved document" message "The frontmost document appears to be unsaved. Please save it with an extension of \"md\" or \"markdown\" before trying again." buttons "OK" default button 1
					error "Unsaved document"
				else
					-- fpath got assigned and needs to be converted into a real posix path.
					set fpath to do shell script "x=" & quoted form of fpath & "
        				x=${x/#file:\\/\\/}
        				printf ${x//%/\\\\x}"
				end if
			on error errmsg
				-- Either there was no path or something else went wrong.
				if errmsg ­ "Unsaved document" then display alert "Can't get file" message "Can't get info on the frontmost document." buttons {"Cancel"} giving up after 30
				set fname to ""
			end try
		end try
		
		-- We got a file path, now make sure it's a markdown file, based on the file extension, checking if there is one.
		if fname contains "." then
			set hasext to true
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "."
			set ext to the last text item of fname
			set AppleScript's text item delimiters to tid
			if ext = "md" or ext = "markdown" then set validFile to true
		end if
		if fname ­ "" and not validFile then
			display alert "Not markdown" as warning message Â
				"The file doesn't appear to be in markdown format. Proceed anyway?" buttons {"Yes", "No"} default button 2 giving up after 30
			if alert reply = "Yes" then
				set validFile to true
			end if
		end if
		
		
		if validFile then
			-- Run the pandoc command using the path we found.
			
			--TO-DO: Let the user choose the output filetype.
			set outputext to ".odt"
			
			set outputfn to fname
			-- Strip the extension when it exists
			if hasext then
				repeat with i from 1 to (number of characters in ext) + 1
					set fname to characters 1 through ((length of fname) - 1) of fname as string
				end repeat
			end if
			-- And then add the new extension
			--    Check for ridiculously long filename
			if length of fname > 251 then set fname to characters 1 thru 251 of fname as string
			set fname to fname & outputext
			set outputFile to choose file name default name fname default location fpath with prompt "Select location for output:"
			set outputFile to quoted form of POSIX path of outputFile
			--TO-DO: Let the user choose whether to open output file once created. Checkbox in output-file dialog box?
			try
				set pandocFlag to the text returned of (display dialog "Enter any special pandoc switches here:" default answer "" buttons {"Never mind", "OK"} default button 2 cancel button 1)
			on error
				set pandocFlag to ""
			end try
			try
				do shell script shcmd & " " & pandocFlag & " -o " & outputFile & " " & quoted form of fpath & " && open " & outputFile
			on error errmsg
				display alert "pandoc error" message "pandoc reported the following error:" & return & return & errmsg
			end try
		end if
	end tell
end run