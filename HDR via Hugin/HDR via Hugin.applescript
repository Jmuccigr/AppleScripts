-- Use binaries included with Hugin to create a basic HDR by just aligning and enfusing the inputted images
-- Version 0.11

on open (filelist)
	set flist to ""
	set userCanceled to false
	set huginPath to "/Applications/Hugin/Hugin.app/Contents/MacOS/"
	
	repeat with i from 1 to the number of items of filelist
		set flist to flist & " " & the quoted form of the POSIX path of item i of filelist
	end repeat
	-- Get enclosing folder for later rm command to clean out intermediate files
	tell application "Finder"
		set fold to the folder of item 1 of filelist as alias
	end tell
	set f to the POSIX path of fold
	
	try
		set dialogResult to display dialog ("Some output files will be saved temporarily and the final file will be in the same folder as the images. Enter a name for them:") default answer "prefix" with title "Output File Prefix"
	on error number -128
		set userCanceled to true
	end try
	
	if not userCanceled then
		set prefix to text returned of dialogResult
		set newFileName to the quoted form of (f & prefix & "_")
		-- First align the images
		try
			do shell script huginPath & "align_image_stack -a " & newFileName & flist
			-- Then enfuse them
			try
				do shell script huginPath & "enfuse -o " & quoted form of (f & "enfuse " & prefix) & ".tif " & newFileName & "*.tif"
				-- Finally get rid of the intermediate files 
				try
					tell application "Finder"
						do shell script "mv " & newFileName & "*.tif ~/.Trash"
					end tell
				on error errStr number errorNumber
					display dialog ("Error moving files to the trash: " & errorNumber & ": " & errStr as string)
				end try
			on error errStr number errorNumber
				display dialog ("Enfuse error " & errorNumber & ": " & errStr as string)
			end try
		on error errStr number errorNumber
			display dialog ("Align error " & errorNumber & ": " & errStr as string)
		end try
	end if
	
end open