-- A script to take the front document in MacDown and have pandoc process it.
-- Assumes that MacDown is the frontmost app, which can be ensured by putting the script in the Scripts folder for MacDown.

global ottfile, dotmfile

on run
	
	-- Some stuff to make it easier to debug this script
	tell application "Finder"
		try
			if (name of processes as string) contains "AppleScript Editor" then set the visible of process "AppleScript Editor" to false
		end try
		tell application "MacDown" to activate
	end tell
	
	-- Set some variables for use later on
	
	set validFile to false
	set ext to ""
	set hasext to false
	set fname to ""
	set fpath to ""
	set outputfile to ""
	set myHome to POSIX path of (path to home folder)
	set myDocs to POSIX path of (path to documents folder)
	set myLib to POSIX path of (path to library folder from user domain)
	-- For pandoc.
	--Use single-quoted form of POSIX path
	set bibfile to "'" & myDocs & "My Library.bib'"
	-- These are the default templates for the output. Use unquoted forms of the POSIX path.
	set ottfile to myLib & "Application Support/LibreOffice/4/user/template/Butterick 11.ott"
	set dotmfile to myLib & "Application Support/Microsoft/Office/User Templates/Normal.dotm"
	-- default output-file extension without leading dot
	set outputext to "odt"
	
	--Wrapping the whole thing in this tell to keep error messages in MacDown (not sure this is necessary)
	tell application "MacDown"
		
		-- Get info for frontmost window	in MacDown
		-- The first part won't ever work for MacDown because it doesn't do applescript.
		try
			set fpath to (path of document 1) as text
			set fname to (name of document 1) as text
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
			end try
		end try
		
		-- We got a file path, now make sure it's a markdown file, based on the file extension, checking if there is one.
		try
			set ext to my get_ext(POSIX file fpath as alias as string)
		on error
			set fname to ""
		end try
		set hasext to (length of ext > 0)
		if ext = "md" or ext = "markdown" then set validFile to true
		
		if fname ­ "" and not validFile then
			set alertResult to display alert "Not markdown" as warning message Â
				"The file doesn't appear to be in markdown format. Proceed anyway?" buttons {"Yes", "No"} default button 2 giving up after 30
			if button returned of alertResult = "Yes" then
				set validFile to true
			end if
		end if
		
		if validFile then
			
			-- Run the pandoc command using the path we found.
			
			--TO-DO: Let the user choose the output filetype.
			
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
			set fname to fname & "." & outputext
			repeat until outputfile ­ ""
				try
					set outputfile to choose file name default name fname default location fpath with prompt "Select location for output:"
					-- Make sure it's got an extension or pandoc won't know what to do with it
					set tid to AppleScript's text item delimiters
					set AppleScript's text item delimiters to ":"
					set outputname to the last text item of (outputfile as string)
					set AppleScript's text item delimiters to tid
					--if outputname does not contain "." then error "no extension"
					if length of (my get_ext(outputname)) = 0 then error "no extension"
					-- Set template for pandoc
					set refFile to my set_refFile(outputfile)
					-- 		change to POSIX form
					set outputfile to quoted form of POSIX path of outputfile
					
					
					--TO-DO: Let the user choose whether to open output file once created. Checkbox in output-file dialog box?
					
					-- Create shell script for pandoc
					--	First have to reset PATH to use homebrew binaries and find xelatex; there are other approaches to this problem.
					set shcmd to "export PATH=/usr/local/bin:/usr/local/sbin:/usr/texbin:$PATH"
					--	Now add the pandoc switches.
					set shcmd to shcmd & "; pandoc -s -S --bibliography=" & bibfile & " --latex-engine=xelatex " & refFile
					
					try
						set dialogResult to (display dialog "Enter any special pandoc switches here:" default answer "" buttons {"Cancel", "Never mind", "OK"} default button 3)
						if the button returned of dialogResult is "OK" then
							set pandocFlag to the text returned of dialogResult
						else
							error (the button returned of dialogResult)
						end if
					on error errmsg
						if errmsg = "MacDown got an error: User canceled." then
							exit repeat -- drop out of the repeat loop and thus the script
						end if
						-- else the button returned is "Never mind"
						set pandocFlag to ""
					end try
					try
						do shell script shcmd & refFile & pandocFlag & " -o " & outputfile & " " & quoted form of fpath & "; open " & outputfile
					on error errmsg
						display alert "pandoc error" message "pandoc reported the following error:" & return & return & errmsg
					end try
				on error errmsg
					if errmsg = "no extension" then
						set alertResult to display alert "No extension" message "The filename must contain an extension, so pandoc knows what type to export it as." buttons {"Cancel", "Retry"} default button 2 cancel button 1
						set outputfile to ""
					else
						exit repeat
					end if
				end try
				
			end repeat -- output filename check
		end if -- validFile check
	end tell
end run

-- Subroutine to set the reference file switch for pandoc
-- File choice is based on ext, the file extension
-- Pad it with spaces.
on set_refFile(filename)
	tell application "MacDown"
		do shell script "touch " & quoted form of (POSIX path of filename)
		set ext to my get_ext(filename as string)
		if ext = "odt" then
			return " --reference-odt='" & POSIX path of (choose file default location (ottfile) with prompt "Select template for odt file:" of type "org.oasis-open.opendocument.text-template") & "' "
		else
			if ext = "docx" or ext = "doc" then
				return " --reference-docx='" & POSIX path of (choose file default location (dotmfile) with prompt "Select template for Word file:" of type "org.openxmlformats.wordprocessingml.template.macroenabled") & "' "
			else
				return " "
			end if
		end if
	end tell
end set_refFile

-- Subroutine to get extension from filename
-- Assumes there is a "." in the passed filename
-- Can't use the "name extension" method because the file doesn't exist yet and we should avoid creating it
on get_ext(filename)
	try
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "."
		set ext to the last text item of filename
		set AppleScript's text item delimiters to tid
		return ext
	on error errmsg
		display dialog "Fatal error getting extension of file: " & errmsg
		error -128
	end try
end get_ext