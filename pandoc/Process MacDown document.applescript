-- A script to take the front document in MacDown and have pandoc process it.
-- Assumes that MacDown is the frontmost app, which can be ensured by putting the script in the Scripts folder for MacDown.

on run
	
	-- Some stuff to make it easier to debug this script
	tell application "Finder"
		set the visible of process "AppleScript Editor" to false
		tell application "MacDown" to activate
	end tell
	
	set fname to ""
	
	-- Create shell script for pandoc
	--	First have to reset PATH to use homebrew binaries; there are other approaches to this problem.
	set shcmd to "export PATH=/usr/local/bin:/usr/local/sbin:$PATH"
	--	Now add the pandoc switches. Note the quoted filepaths.
	set shcmd to shcmd & "; pandoc -s -S --latex-engine=xelatex --reference-odt='/Users/john_muccigrosso/Library/Application Support/LibreOffice/4/user/template/Butterick 11.ott' --bibliography='/Users/john_muccigrosso/Documents/My Library.bib'"
	
	-- Get info for frontmost window	in MacDown
	set validFile to false
	try
		tell application (path to frontmost application as text)
			set fpath to (path of document 1) as text
			set fname to (name of document 1) as text
		end tell
	on error
		try
			tell application "System Events" to tell (process 1 where frontmost is true)
				set fpath to value of attribute "AXDocument" of window 1
				set fname to value of attribute "AXTitle" of window 1
			end tell
			set fpath to do shell script "x=" & quoted form of fpath & "
        				x=${x/#file:\\/\\/}
        				printf ${x//%/\\\\x}"
		on error
			display alert "Can't get file" message "Can't get info on the frontmost document." buttons {"Cancel"}
			set fname to ""
		end try
	end try
	--display dialog fname
	-- Make sure it's a markdown file, based on the file extension
	if fname contains "." then
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "."
		set ext to the last text item of fname
		set AppleScript's text item delimiters to tid
		if ext = "md" or ext = "markdown" then set validFile to true
	end if
	if fname ­ "" then
		display alert "Not markdown" as warning message Â
			"The file doesn't appear to be in markdown format. Proceed anyway?" buttons {"Yes", "Cancel"} default button 2
		if alert reply = "OK" then
			set validFile to true
		end if
	end if
	
	
	-- Run the pandoc command using that path
	if validFile then
		set outputext to ".odt"
		
		set outputfn to "/Users/john_muccigrosso/Downloads/" & fname
		repeat with i from 1 to (number of characters in ext) + 1
			set outputfn to characters 1 through ((length of outputfn) - 1) of outputfn as string
		end repeat
		set outputfn to "'" & outputfn & outputext & "'"
		--quoted form of fpath
		--	outputfn
		do shell script shcmd & " -o " & outputfn & " " & quoted form of fpath & " && open " & outputfn
	end if
end run