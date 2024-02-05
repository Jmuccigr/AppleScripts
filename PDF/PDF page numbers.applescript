# An app to overlay page numbers on an existing PDF

on open of finderObjects
	# Get only the first of multiple items
	set fname to item 1 of finderObjects
	# Make sure the file is a PDF, based on file info
	set ftype to (do shell script "file -bI " & quoted form of (POSIX path of fname))
	if characters 1 thru 15 of ftype as string ­ "application/pdf" then
		display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
		error number -128
	end if
	
	# Get some info on the file
	tell application "Finder" to set fpath to container of file fname
	set pfile to quoted form of the POSIX path of fname
	
	# Initialize some variables
	set paperSize to "none"
	set paperChoice to "none"
	set sizes to {"A4", "A4 landscape", "letter", "letter landscape"}
	set orientation to ""
	set qpdfPath to "/opt/homebrew/bin/qpdf"
	set infoPath to "/opt/homebrew/bin/pdfinfo"
	set latexPath to "/Library/TeX/texbin/pdflatex"
	
	# Get number of pages & their size
	set pageCount to (do shell script infoPath & " " & pfile & " | grep Pages | sed 's/Pages://'") as number
	set pageSize to (do shell script infoPath & " " & pfile & " | grep \"Page size:\" | sed 's/^.*(//' | sed 's/).*//'")
	
	# Set page size based on the existing file, if readable, or ask for input
	if pageSize is in {"letter", "A4"} then
		if pageSize is "letter" then
			set paperSize to pageSize
		else
			set paperSize to "a4paper"
		end if
	else
		try
			set paperChoice to {choose from list sizes with title "Paper Size" default items "A4" cancel button name "Cancel" without multiple selections allowed and empty selection allowed}
			if (paperChoice as string) contains "A4" then
				set paperSize to "a4paper"
			else
				if (paperChoice as string) contains "letter" then
					set paperSize to "letterpaper"
				else -- the user has canceled
					quit
				end if
			end if
		on error errMsg number errNum
			display alert "Error!" message "Something went wrong getting the paper size: " & return & errMsg
			quit
		end try
	end if
	
	if (paperChoice as string) contains "landscape" then set orientation to ", landscape"
	
	try
		
		# Allow for choice of starting-page number
		set pageReply to (display dialog "Starting page number" with title "Start Page" with icon note default answer "1")
		set startPage to the text returned of pageReply as integer
		
		# Allow placement of page number on page
		set locationChoices to {"Left", "Center", "Right"}
		set placeReply to choose from list locationChoices with prompt "Where do you want the page number placed?" default items {"Center"}
		set placeReply to character 1 of (placeReply as text)
		
		# Allow for leading text
		set textReply to (display dialog "Enter any leading text, including the trailing space:" with title "Text" with icon note default answer "p. ")
		set textReply to the text returned of textReply
		
		# Allow for font size
		set sizeChoices to {"7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "24", "36"}
		set sizeReply to choose from list sizeChoices with prompt "What size font would you like?" default items {"12"}
		
		# Allow for choice of margins
		set marginReply to (display dialog "How many centimeters of side margin do you want? The default is pretty narrow." with title "Margins" with icon note default answer "1")
		set hMargin to the text returned of marginReply as number
		set marginReply to (display dialog "How many centimeters of bottom margin do you want? The default is pretty narrow." with title "Margins" with icon note default answer "1")
		set vMargin to the text returned of marginReply as number
		
		# Allow font choice
		set fontChoices to {"Mono", "Sans serif", "Serif"}
		set fontReply to (choose from list fontChoices with prompt "What kind of font do you want?" default items {"Serif"}) as text
		if fontReply = "Mono" then
			set fontChoice to "ttdefault"
		else
			if fontReply = "Sans serif" then
				set fontChoice to "sfdefault"
			else
				set fontChoice to "rmdefault"
			end if
		end if
		
		# Create a PDF with numbered pages for merging
		do shell script "echo '\\documentclass[12pt," & paperSize & "]{article}\n \\usepackage{multido}\n \\usepackage[hmargin=" & hMargin & "cm,vmargin=" & vMargin & "cm,nohead,nofoot" & orientation & "]{geometry}\n \\\\renewcommand{\\\\familydefault}{\\\\" & fontChoice & "}\n \\usepackage{fancyhdr}\n \\pagestyle{fancy} \n \\\\fancyhf{} \\\\renewcommand{\\\\headrulewidth}{0pt} \\\\fancyfoot[" & placeReply & "]{\\\\fontsize{" & sizeReply & "}{10} \\\\selectfont " & textReply & "\\\\thepage} \\\\begin{document}\n \\\\setcounter{page}{" & startPage & "}\n\\multido{}{" & pageCount & "}{\\\\vphantom{x}\\\\newpage}\n \\end{document}' > $TMPDIR/numbers.tex"
		do shell script ("cd $TMPDIR; " & latexPath & " $TMPDIR/numbers.tex")
	on error errMsg number errNum
		if errMsg is not "User canceled." then display alert "Error!" message "Something went wrong creating the numbered pages: " & return & errMsg
		error number -128
	end try
	
	# Get just the filename for saving
	set filename to (do shell script "filename=`basename " & pfile & "`; filename=${filename%.*}; echo $filename")
	
	# Overlay the numbered file on the original & save to a new PDF file
	set resultFile to (choose file name with prompt "Save As File" default name filename & "_numbered.pdf" default location fpath as alias)
	if resultFile as string does not end with ".pdf" then
		set outputFile to (resultFile as string) & ".pdf"
	else
		set outputFile to (resultFile as string)
	end if
	set theResult to (do shell script "cd $TMPDIR; " & qpdfPath & " " & pfile & " --underlay numbers.pdf -- " & quoted form of POSIX path of outputFile)
	
	-- Notify of completion
	if theResult is "" then
		display notification ("Your PDF now has page numbers.") with title "Numbering done" sound name "beep"
	else
		display alert "Problem!" message "There was a problem creating the PDF with page numbers:" & return & return * theResult
	end if
	
end open