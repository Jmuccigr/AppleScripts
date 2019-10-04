on open fname
	# Make sure the file is a PDF, based on extension
	tell application "Finder"
		set ext to (name extension of file fname) as string
	end tell
	set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
	if ext is not "pdf" then
		display alert "Wrong file type" message "This does not appear to be a PDF file. Quitting."
		quit
	end if
	
	tell application "Finder" to set fpath to container of file fname
	set pfile to quoted form of the POSIX path of fname
	
	set paperSize to "none"
	set paperChoice to "none"
	set sizes to {"A4", "letter", "A4 landscape", "letter landscape"}
	set orientation to ""
	
	# Get number of pages for input checking
	set tkPath to "/usr/local/bin/pdftk"
	set infoPath to "/usr/local/bin/pdfinfo"
	set latexPath to "/Library/TeX/texbin/pdflatex"
	set pageCount to (do shell script infoPath & " " & pfile & " | grep Pages | sed 's/Pages://'") as number
	set pageSize to (do shell script infoPath & " " & pfile & " | grep \"Page size:\" | sed 's/^.*(//' | sed 's/).*//'")
	# Get page size
	if pageSize is in {"letter", "A4"} then
		set paperSize to pageSize
	else
		try
			set paperChoice to {choose from list sizes with title "Paper Size" default items "A4" cancel button name "Cancel" without multiple selections allowed and empty selection allowed}
			if ((paperChoice as string) contains "A4") then
				set paperSize to "a4paper"
			else
				if (paperChoice as string) contains "letter" then
					set paperSize to "letterpaper"
				else
					quit
				end if
			end if
		on error errMsg number errNum
			display alert "Error!" message "Something went wrong 1: " & return & errMsg
			quit
		end try
	end if
	
	if (paperChoice as string) contains "landscape" then set orientation to ", landscape"
	
	try
		do shell script "echo '\\documentclass[12pt," & paperSize & "]{article}\n \\usepackage{multido}\n \\usepackage[hmargin=.8cm,vmargin=1.5cm,nohead,nofoot" & orientation & "]{geometry}\n \\\\begin{document}\n \\multido{}{" & pageCount & "}{\\\\vphantom{x}\\\\newpage}\n \\end{document}' > $TMPDIR/numbers.tex"
		do shell script ("cd $TMPDIR; " & latexPath & " $TMPDIR/numbers.tex")
	on error errMsg number errNum
		display alert "Error!" message "Something went wrong: " & return & errMsg
	end try
	
	# Get just filename for saving
	set filename to (do shell script "filename=`basename " & pfile & "`; filename=${filename%.*}; echo $filename")
	
	set resultFile to (choose file name with prompt "Save As File" default name filename & "_numbered.pdf" default location fpath as alias)
	do shell script "cd $TMPDIR; " & tkPath & " " & pfile & " multistamp numbers.pdf output " & quoted form of POSIX path of resultFile
end open