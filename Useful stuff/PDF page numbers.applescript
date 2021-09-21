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
	set qpdfPath to "/usr/local/bin/qpdf"
	set infoPath to "/usr/local/bin/pdfinfo"
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
	
	# Allow for choice of start-page number
	set pageReply to (display dialog "Starting page number" with title "Start Page" with icon note default answer "1")
	set startPage to the text returned of pageReply as integer
	
	# Create a PDF with numbered pages for merging
	try
		do shell script "echo '\\documentclass[12pt," & paperSize & "]{article}\n \\usepackage{multido}\n \\usepackage[hmargin=.8cm,vmargin=.75cm,nohead,nofoot" & orientation & "]{geometry}\n \\\\begin{document}\n \\\\setcounter{page}{" & startPage & "}\n\\multido{}{" & pageCount & "}{\\\\vphantom{x}\\\\newpage}\n \\end{document}' > $TMPDIR/numbers.tex"
		do shell script ("cd $TMPDIR; " & latexPath & " $TMPDIR/numbers.tex")
	on error errMsg number errNum
		display alert "Error!" message "Something went wrong creating the numbered pages: " & return & errMsg
	end try
	
	# Get just filename for saving
	set filename to (do shell script "filename=`basename " & pfile & "`; filename=${filename%.*}; echo $filename")
	
	# Overlay the numbered file on the original & save to a new PDF file
	set resultFile to (choose file name with prompt "Save As File" default name filename & "_numbered.pdf" default location fpath as alias)
	if resultFile as string does not end with ".pdf" then
		set outputFile to (resultFile as string) & ".pdf"
	else
		set outputFile to (resultFile as string)
	end if
	do shell script "cd $TMPDIR; " & qpdfPath & " " & pfile & " --underlay numbers.pdf -- " & quoted form of POSIX path of outputFile
	
	-- Notify of completion
	display notification ("Your PDF now has page numbers.") with title "Numbering done" sound name "beep"
	
end open