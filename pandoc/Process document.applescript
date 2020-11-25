-- A script to take the front document in the frontmost application and have pandoc process it.

global appName, ottfile, dotmfile, pptxthemefile, outputFormats, output_format_list, outputExt, pandocSwitches, beamerConfig, htmlConfig, html5Config, revealConfig, pdfConfig, refFile, myName, filterText

on run
	-- Set some variables for use later on
	set ASmethod to false
	set validFile to false
	set hasext to false
	set appName to ""
	set ext to ""
	set fname to ""
	set fpath to ""
	set outputfile to ""
	
	-- Some needed paths
	set myDocs to POSIX path of (path to documents folder)
	set myGit to myDocs & "github/local/"
	set myLib to POSIX path of (path to library folder from user domain)
	set myName to (do shell script "whoami")
	
	-- For pandoc
	-- Use single-quoted form of POSIX path
	set bibfile to quoted form of (myGit & "miscellaneous/My Library.json")
	
	-- These are the default templates for the output. Use unquoted forms of the POSIX path.
	set ottfile to myLib & "Application Support/LibreOffice/4/user/template/Butterick 11.ott"
	set dotmfile to myLib & "Application Support/Microsoft/Office/User Templates/Normal.dotm"
	set pptxthemefile to myLib & "Application Support/Microsoft/Office/User Templates/My Templates/pandoc.potx"
	
	-- output options
	set outputFormats to {"html", "html5", "latex", "pdf", "odt", "docx", "beamer", "slidy", "slideous", "dzslides", "pptx", "revealjs", "s5", "native", "json", "plain", "markdown", "markdown_strict", "markdown_phpextra", "gfm", "markdown_mmd", "commonmark", "rst", "context", "man", "mediawiki", "dokuwiki", "textile", "org", "texinfo", "opml", "docbook", "opendocument", "haddock", "rtf", "epub", "epub2", "epub3", "fb2", "asciidoc", "icml"}
	
	-- default output-file extension without leading dot
	set outputExt to "html"
	
	-- Variables specific to output types.
	-- For reveal.js, use  "--variable revealjs-url=http://lab.hakim.se/reveal-js" if local reveal.js is lacking.
	-- Removing ' -V width=\\" & quote & "& quote & "100%\\" ' while bug prevents correct thumbnails
	set beamerConfig to "+smart --pdf-engine=xelatex -i --template=" & quoted form of (myGit & "pandoc-templates/default.latex") & " -V theme=Madrid -V colortheme=beetle -V fonttheme=structuresmallcapsserif"
	set htmlConfig to "+smart --self-contained --template=" & quoted form of (myGit & "pandoc-templates/default.html4")
	set html5Config to "+smart --self-contained --template=" & quoted form of (myGit & "pandoc-templates/default.html5")
	set pdfConfig to "+smart --pdf-engine=xelatex --template=" & quoted form of (myGit & "pandoc-templates/default.latex")
	set revealConfig to "+smart -i --self-contained -V center=false -V theme=gray_lecture -V transition=fade -V transitionSpeed=slow -V width=\\" & quote & "100%\\" & quote & " -V height=\\" & quote & "100%\\" & quote & " -V margin=0 -V revealjs-url=" & quoted form of (myGit & "reveal.js/")
	
	-- Standard variables
	set pandocSwitches to " -s --columns 800 --bibliography=" & bibfile
	set filterText to ""
	
	tell application "System Events"
		try
			set appName to (the name of every process whose frontmost is true) as string
		on error errMsg
			display alert "Problem" message "Could not get the name of the frontmost application."
			error number -128
		end try
	end tell
	
	--Wrapping the whole thing in this tell to keep error messages in the application (not sure this is necessary)
	tell application appName
		activate
		-- Get info for frontmost window
		-- The first part won't ever work for MacDown because it doesn't have "path" in its applescript properties, but maybe someday.
		try
			set fpath to (path of document 1) as text
			set fname to (name of document 1) as text
			set ASmethod to true
		on error
			try
				tell application "System Events" to tell (process 1 where name is appName)
					--Not sure why, but the following is needed with certain apps (e.g., BBEdit 8)
					activate
					set fpath to value of attribute "AXDocument" of window 1
					set fname to value of attribute "AXTitle" of window 1
				end tell
			on error errMsg
				-- Something went wrong.
				display alert "Can't get file" message "Can't get info on the frontmost document:" & return & return & errMsg buttons {"OK"} giving up after 30
				error number -128
			end try
		end try
		-- When the document hasn't been saved, fpath gets assigned "" or "missing value", depending on the method used above.
		activate
		if fpath is missing value or fpath = "" then
			display alert "Unsaved document" message "The frontmost document appears to be unsaved. Please save it with an extension of \"md\" or \"markdown\" before trying again." buttons "OK" default button 1
			error number -128
		else
			if not ASmethod then
				-- fpath got assigned by second method and needs to be converted into a real posix path.
				-- Second substitution needed because of varying form of fpath value from BBEdit 8. Could be outdated.
				set fpath to do shell script "x=" & quoted form of fpath & "\n        \t\t\t\tx=${x/#file:\\/\\/}\n        \t\t\t\tx=${x/#localhost}\n        \t\t\t\tprintf ${x//%/\\\\x}"
			end if
		end if
		-- We got a file path, now make sure it's a markdown file, based on the file extension, checking if there is one.
		-- To-do: check against list of valid extensions and let user pick or override the input type.
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
			set outputfn to fname
			-- Strip the extension when it exists
			if hasext then
				repeat with i from 1 to (number of characters in ext) + 1
					set outputfn to characters 1 through ((length of outputfn) - 1) of outputfn as string
				end repeat
			end if
			-- And then add the new extension
			--    Check for ridiculously long filename
			if length of outputfn > 251 then set outputfn to characters 1 thru 251 of outputfn as string
			set {outputExt, pandocUserSwitches} to my get_output()
			if outputExt is "" then error number -128
			set outputfn to outputfn & "." & outputExt
			set fpath to (do shell script "dirname  " & quoted form of fpath) & "/"
			repeat until outputfile ­ ""
				try
					set outputfile to choose file name default name outputfn default location fpath with prompt "Select location for output:"
					-- Complain if it doesn't have an extension.
					set tid to AppleScript's text item delimiters
					set AppleScript's text item delimiters to ":"
					set outputname to the last text item of (outputfile as string)
					set AppleScript's text item delimiters to tid
					--if outputname does not contain "." then error "no extension"
					if length of (my get_ext(outputname)) = 0 then error "no extension"
				on error errMsg
					if errMsg = "no extension" then
						set alertResult to button returned of (display alert "No extension" message "The filename usually contains an extension, so your system will know how to open the resulting file." buttons {"Leave it alone", "Cancel", "Retry"} default button 3 cancel button 2)
						if alertResult = "Retry" then
							set outputfile to ""
						else -- result was "leave it alone"
							exit repeat
						end if
					else
						error number -128
					end if
				end try
			end repeat -- output filename check
			
			--TO-DO: Let the user choose whether to open output file once created. Checkbox in output-file dialog box?
			
			-- Change to POSIX form
			set outputfile to quoted form of POSIX path of outputfile & " "
			-- Create shell script for pandoc
			--	First have to reset PATH to use homebrew binaries and find xelatex; there are other approaches to this 
			--    Switch to directory where working file is so relative paths (e.g., for images) work
			set shcmd to "export PATH=/usr/local/bin:/usr/local/sbin:/Library/TeX/texbin:$PATH; cd " & quoted form of fpath & "; "
			--	Now add the pandoc switches based on config at top and user input.
			set shcmd to shcmd & "pandoc " & quoted form of fname & pandocUserSwitches
			-- Run the pandoc command & open the resulting file
			try
				set the clipboard to shcmd & "-o " & outputfile
				do shell script shcmd & "-o " & outputfile
				do shell script "open " & outputfile
			on error errMsg
				display alert "pandoc error" message "pandoc reported the following error:" & return & return & errMsg
			end try
		end if -- validFile check
	end tell
end run

-- Subroutine to set the reference file switch for pandoc
-- File choice is based on the selected output-file type
on set_refFile(output_format_list)
	try
		if output_format_list = "odt" then
			return "--reference-doc='" & POSIX path of (choose file default location (ottfile) with prompt "Select template for odt file:" of type "org.oasis-open.opendocument.text-template") & "'"
		else
			if output_format_list = "docx" or output_format_list = "doc" then
				return "--reference-doc='" & POSIX path of (choose file default location (dotmfile) with prompt "Select template for Word file:" of type "org.openxmlformats.wordprocessingml.template.macroenabled") & "'"
			else
				return ""
			end if
		end if
	on error errMsg
		if errMsg = "User canceled." then
		else
			display alert "Error" message "Fatal error getting reference file: " & errMsg
		end if
		error number -128
	end try
end set_refFile

-- Subroutine to get extension from filename
-- Assumes there is a "." in the passed filename
-- Can't use the "name extension" method because the file doesn't exist yet and we should avoid creating it
on get_ext(filename)
	try
		if filename does not contain "." then
			set ext to ""
		else
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "."
			set ext to the last text item of filename
			set AppleScript's text item delimiters to tid
		end if
		return ext
	on error errMsg
		display alert "Error" message "Fatal error getting extension of file: " & errMsg
		error number -128
	end try
end get_ext

on get_output()
	set otherReply to "Cancel"
	set output_extension to ""
	set output_format_list to ""
	set options to ""
	set otherOptions to ""
	set refFile to ""
	
	try
		tell me to activate
		set outputDialogResult to {choose from list outputFormats with title "Pandoc: Specify output format(s)" with prompt "What output format do you want?" default items outputExt}
		try
			if not outputDialogResult then error "User canceled."
		end try
		set output_format_list to (outputDialogResult as text)
		if output_format_list is in (outputFormats as text) then
			--set output_format_list to outputDialogResult
			-- Display a dialog box with specified input and output formats, so you can cancel if you made any mistakes and specify more command-line options via a text field. You can change the default answer if you prefer a different one.
			-- First create options for a given subset of output types.
			if output_format_list is in {"html", "html5", "pdf", "revealjs", "beamer"} then
				if output_format_list is "html" then
					set pandocSwitches to htmlConfig & " " & pandocSwitches
				else if output_format_list is "html5" then
					set pandocSwitches to html5Config & " " & pandocSwitches
				else if output_format_list is "pdf" then
					set pandocSwitches to pdfConfig & " " & pandocSwitches
				else if output_format_list is "revealjs" then
					set pandocSwitches to revealConfig & " " & pandocSwitches
				else if output_format_list is "beamer" then
					set pandocSwitches to beamerConfig & " " & pandocSwitches
				end if
			end if
			-- Set template file for output where needed.
			set refFile to my set_refFile(output_format_list)
			-- Check for filters to run. Assumes filters have been copied into pandoc's default data directory
			set filterChoices to paragraphs of (do shell script "ls /Users/" & myName & "/.local/share/pandoc/filters/")
			set filterCount to 0
			repeat with filter in filterChoices
				set filterchoice to (display dialog "Do you want to run the filter " & filter & "?" buttons {"Cancel", "Yes", "No"} default button 3)
				if button returned of filterchoice = "Yes" then
					set filterText to filterText & " --filter " & filter
					set filterCount to filterCount + 1
				end if
			end repeat
			-- Allow manual settings
			set optionsDialogResult to display dialog "Output format: " & output_format_list & return & return & "To add more command-line options, use the field below." & return & return & "Some reader options:" & return & "+smart --parse-raw --old-dashes --base-header-level=NUMBER --indented-code-classes=CLASSES --default-image-extension=EXTENSION --metadata=KEY[:VAL] --normalize --preserve-tabs --tab-stop=NUMBER --track-changes=accept|reject|all --extract-media=DIR" & return & return & "Some writer options:" & return & "+smart --data-dir=DIRECTORY --standalone  --self-contained --no-wrap --columns=NUMBER --toc --toc-depth=NUMBER --no-highlight --highlight-style=STYLE" & return & return & "Some options affecting specific writers:" & return & "--ascii --reference-links --chapters --number-sections --number-offset=NUMBER[,NUMBER,...] --no-tex-ligatures --listings --incremental --slide-level=NUMBER --section-divs --email-obfuscation=none|javascript|references --id-prefix=STRING --css=URL --pdf-engine=pdflatex|lualatex|xelatex --pdf-engine-opt=STRING --bibliography=FILE" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" default answer pandocSwitches with title "Pandoc: Specify other options"
			if button returned of optionsDialogResult is "OK" then
				-- User didn't cancel, so grab those responses
				-- To-do: investigate using an array of extensions and doing a lookup.
				set options to text returned of optionsDialogResult
				-- set otherOptions to text returned of otherDialogResult
				-- set the output extension
				if output_format_list is "native" then
					set output_extension to "hs"
				end if
				if output_format_list is "haddock" then
					set output_extension to "-hs"
				end if
				if output_format_list is "json" then
					set output_extension to "json"
				end if
				if output_format_list is in {"plain", "mediawiki", "dokuwiki", "asciidoc"} then
					set output_extension to "txt"
				end if
				if output_format_list is in {"markdown", "markdown_strict", "markdown_phpextra", "gfm", "markdown_mmd", "commonmark"} then
					set output_extension to "md"
				end if
				if output_format_list is "rst" then
					set output_extension to "rst"
				end if
				if output_format_list is in {"html", "html5", "slidy", "slideous", "dzslides", "revealjs", "s5"} then
					set output_extension to "html"
				end if
				if output_format_list is "pptx" then
					set output_extension to "pptx"
				end if
				if output_format_list is in {"latex", "context"} then
					set output_extension to "tex"
				end if
				if output_format_list is "pdf" then
					set output_extension to "pdf"
					set output_format_list to "latex"
				end if
				if output_format_list is "beamer" then
					set output_extension to "pdf"
				end if
				if output_format_list is "rst" then
					set output_extension to "rst"
				end if
				if output_format_list is "man" then
					set output_extension to "man"
				end if
				if output_format_list is "textile" then
					set output_extension to "textile"
				end if
				if output_format_list is "org" then
					set output_extension to "org"
				end if
				if output_format_list is "texinfo" then
					set output_extension to "texi"
				end if
				if output_format_list is "opml" then
					set output_extension to "opml"
				end if
				if output_format_list is "docbook" then
					set output_extension to "db"
				end if
				if output_format_list is "opendocument" then
					set output_extension to "xml"
				end if
				if output_format_list is "odt" then
					set output_extension to "odt"
				end if
				if output_format_list is "docx" then
					set output_extension to "docx"
				end if
				if output_format_list is "rtf" then
					set output_extension to "rtf"
				end if
				if output_format_list is in {"epub", "epub2", "epub3"} then
					set output_extension to "epub"
				end if
				if output_format_list is "fb2" then
					set output_extension to "fb2"
				end if
				if output_format_list is "icml" then
					set output_extension to "icml"
				end if
			else
				error "User canceled."
			end if
		end if
		-- Return the extension and the concatenated options
		return {output_extension, filterText & " -t " & output_format_list & options & space & refFile & space}
	on error errMsg
		if errMsg ­ "User canceled." then
			display alert "Output File Error:" message errMsg
		end if
		error number -128
	end try
end get_output
