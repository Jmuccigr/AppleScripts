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
	
	# Set file types to be handled
	set filetypes to "  -png -tiff -j -jp2 -ccitt "
	
	# Use the version of the script embedded in the app
	set imagePath to quoted form of ((POSIX path of (path to me) as string) & "Contents/Resources/pdfimages")
	set infoPath to quoted form of ((POSIX path of (path to me) as string) & "Contents/Resources/pdfinfo")
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/"
	
	# Make sure there are images in the file
	set imageCount to ((do shell script (imagePath & " -list " & quoted form of pfile & " | wc -l")) as integer) - 2
	if imageCount = 0 then
		display alert "No images!" message "Oops. This file has no images in it."
		quit
	end if
	
	# If there are a lot of images in the file, make sure that's ok
	if imageCount > 100 then
		set reply to (display dialog "This file has " & imageCount & " images in it. Do you want to continue?" with title "Lots of images!" buttons {"Yes", "No"} default button 1 cancel button 2)
	end if
	
	# Get number of pages for input checking
	set pageCount to (do shell script infoPath & " " & quoted form of pfile & " | grep Pages | sed 's/Pages://'") as number
	
	# Get pages to process, making sure that they're valid pages for the document
	repeat with i from 1 to pageCount
		set outputname to (i as string)
		repeat until the number of characters in outputname = 4
			set outputname to "0" & outputname
		end repeat
		do shell script (imagePath & filetypes & " -f " & i & " -l " & i & " " & quoted form of pfile & " " & quoted form of (fpath & outputname))
	end repeat
end open