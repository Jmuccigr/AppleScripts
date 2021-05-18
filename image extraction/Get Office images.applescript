-- Script to extract images from MS Word or PowerPoint files
-- For PowerPoints, it can also extract by slide

on open fname
	# Make sure the file is a MS Office file, based on extension
	tell application "Finder"
		set ext to (name extension of file fname) as string
	end tell
	set ext to (do shell script "echo " & ext & " | tr '[:upper:]' '[:lower:]'")
	if ext is not in {"docx", "pptx"} then
		display alert "Wrong file type" message "This does not appear to be a new Word or PowerPoint file. Quitting."
		quit
	end if
	
	set openParens to "{"
	set closeParens to "}"
	set slideinfo to ""
	
	-- Set appropriate dir name depending on file type
	if ext = "docx" then
		set mspath to "word"
		set unit to "page"
		set reply to ""
	else
		set mspath to "ppt"
		set unit to "slide"
	end if
	
	# Get the page or slide numbers for the images
	if ext = "pptx" then
		set reply to the text returned of (display dialog "Enter the " & unit & "s you want to extract images from." & return & return & "The format should be a list of numbers separated by commas. To get all the images, just leave the field blank." buttons {"Cancel", "Extract"} default button 2 default answer "")
		if reply is not "" then
			set reply to (do shell script "echo " & reply & " | sed 's/ //g'")
			if reply does not contain "," then
				set openParens to ""
				set closeParens to ""
			end if
		end if
	end if
	# Create likely unique name for destination folder
	# System will create the new folder automatically
	tell application "Finder"
		set fnameString to characters 1 thru 15 of (((name of file fname) as string) & "              ") as string
		set fnameString to (do shell script "echo " & quoted form of fnameString & " | tr ' ' '_'")
	end tell
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	
	# Get info on the file
	set pfile to the POSIX path of fname
	set fpath to (do shell script "dirname " & quoted form of pfile) & "/" & dateString & "_" & fnameString & "_images"
	
	# Extract files in the media directory into the same folder as the file.
	if reply is "" then
		try
			do shell script "unzip -n -j -d " & quoted form of fpath & " " & quoted form of pfile & " " & mspath & "/media/*"
		on error
			display alert "Problem!" message "There don't seem to be any images in this file. Or it could be corrupt."
			do shell script ("rmdir " & quoted form of fpath)
		end try
	else
		set zipfolder to (do shell script "echo $TMPDIR") & "imageextract_" & dateString & "/"
		do shell script "unzip -d " & zipfolder & space & quoted form of pfile
		set slideCount to (do shell script "ls -l " & zipfolder & "/ppt/slides/slide* " & " | wc -l") + 1 as integer
		try
			set slideinfo to (do shell script "for i in " & openParens & reply & closeParens & "; do if [ $i -lt " & slideCount & " ]; then cat " & zipfolder & mspath & "/" & unit & "s/_rels/" & unit & "\"$i\".xml.rels | perl -pe 's/>/\n/g' | grep \"media/image\"; fi;done")
		end try
		if slideinfo ­ "" then
			do shell script ("mkdir " & quoted form of fpath)
			repeat with image in the paragraphs of slideinfo
				set image to my replace(image, "/", return)
				set image to the paragraph ((count of paragraphs of image) - 1) of image
				set image to my replace(image, quote, "")
				-- Since we've already extracted the images, just move them now
				do shell script "mv " & zipfolder & mspath & "/media/" & image & space & quoted form of fpath & "/" & image
				-- Notify of completion
				display notification ("Finished extracting images from your file.") with title "Image extraction" sound name "beep"
			end repeat
		else
			display alert "No images!" message "The file has no images where you wanted to extract them from."
		end if
	end if
end open

-- Quick search and replace with TID
on replace(origtext, ftext, rtext)
	set tid to AppleScript's text item delimiters
	set newtext to origtext
	set AppleScript's text item delimiters to ftext
	set newtext to the text items of newtext
	set AppleScript's text item delimiters to rtext
	set newtext to the text items of newtext as string
	set AppleScript's text item delimiters to tid
	return newtext
end replace
