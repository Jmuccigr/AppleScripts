-- Use binaries included with Hugin to create a basic exposure- or focus-fused output image by just aligning and enfusing the inputted images
-- Version 0.13

on run
	display dialog "Please run this script by dropping images files onto it."
	error number -128
end run

on open (filelist)
	-- Set some variables
	set flist to ""
	set userCanceled to false
	set huginPosixPath to "/Applications/Hugin/Hugin.app/Contents/MacOS/"
	set HuginPresent to true
	
	-- Make sure Hugin is installed in the expected place and quit with instructions if it isn't
	try
		set HuginPath to (path to applications folder as text) & "Hugin:Hugin.app" as alias
	on error errStr number errorNumber
		if errorNumber = -43 then
			display dialog "The Hugin app is not in the expected place. Please move it to the top level of the main Applications folder."
			error number -128
		else
			display dialog errorNumber & ": " & errStr
		end if
	end try
	
	-- Do the work
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
			do shell script huginPosixPath & "align_image_stack -a " & newFileName & flist
			-- Then enfuse them
			try
				do shell script huginPosixPath & "enfuse -o " & quoted form of (f & "enfuse " & prefix) & ".tif " & newFileName & "*.tif"
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