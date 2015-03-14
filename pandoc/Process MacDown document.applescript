on run
	-- Some stuff to make it easier to debug this script
	tell application "Finder"
		set the visible of process "AppleScript Editor" to false
		tell application "MacDown" to activate
	end tell
	
	-- Get info for frontmost window	in MacDown
	set validFile to false
	repeat until validFile is true
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
			end try
			
			
			-- Make sure it's a markdown file, based on the file extension
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "."
			set ext to the last text item of fname
			set AppleScript's text item delimiters to tid
			if ext = "md" or ext = "markdown" then
				set validFile to true
			else
				display alert "Not markdown" message "The file doesn't appear to be in markdown format."
			end if
		end try
	end repeat
	
	-- Have to reset path to use homebrew binaries
	set shcmd to "export PATH=/usr/local/bin:/usr/local/sbin:$PATH"
	set shcmd to shcmd & "; pandoc -s -S --latex-engine=xelatex --reference-odt='/Users/john_muccigrosso/Library/Application Support/LibreOffice/4/user/template/Butterick 11.ott' --bibliography='/Users/john_muccigrosso/Documents/My Library.bib'"
	
	-- Run the pandoc command using that path
	set outputext to ".odt"
	
	set outputfn to "/Users/john_muccigrosso/Downloads/" & fname
	repeat with i from 1 to (number of characters in ext) + 1
		set outputfn to characters 1 through ((length of outputfn) - 1) of outputfn as string
	end repeat
	set outputfn to "'" & outputfn & outputext & "'"
	--quoted form of fpath
	--	outputfn
	do shell script shcmd & " -o " & outputfn & " " & quoted form of fpath & " && open " & outputfn
	
end run