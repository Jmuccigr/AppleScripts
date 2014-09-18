-- Use binaries included with Hugin to create a basic exposure- or focus-fused output image by just aligning and enfusing the inputted images
-- Version 0.14

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
	set paramValid to false
	set paramString to ""
	
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
	
	-- Check for parameters for enfuse from the user
	try
		repeat until paramValid is true
			set reply to display dialog "Enter any parameter strings you'd like to pass to enfuse:" default answer "" with title "enfuse parameters" buttons {"None", "OK"} default button "None"
			if not (button returned of reply is "None" or text returned of reply = "") then
				set paramString to the text returned of reply & "  " -- pad the reply to catch when the user pressed OK instead of None but entered no text
				if (characters 1 thru 2 of paramString as string ­ "--") or (length of paramString = 4) then
					--					(display dialog) & characters 1 thru 2 of paramString = "--"
					try
						set reply to display dialog "That does not appear to be a valid set of parameters." with title "Invalid parameters" with icon caution buttons ["Never mind", "Try Again"] default button 2
						if button returned of reply = "Never mind" then error "nevermind"
					on error "nevermind"
						set paramValid to true
						set paramString to ""
						--display dialog ">" & paramString & "<"
						
					end try
				else
					set paramValid to true
				end if
			else
				set paramValid to true
			end if
			
		end repeat
	on error number -128
		set userCanceled to true
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
			with timeout of 60 * 60 seconds -- give it an hour
				set command to huginPosixPath & "align_image_stack -a " & newFileName & (display dialog command)
				do shell script command
			end timeout
			-- Then enfuse them
			try
				with timeout of 60 * 60 seconds -- give it an hour
					set command to huginPosixPath & "enfuse " & paramString & " -o " & quoted form of (f & "Bracketed " & prefix) & ".tif " & newFileName & "*.tif"
					--display dialog command
					do shell script command
				end timeout
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
