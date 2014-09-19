-- Use binaries included with Hugin to create a basic exposure- or focus-fused output image by just aligning and enfusing the inputted images
-- Version 0.17

on run
	display alert "Oh, no!" message "Please run this script by dropping images files onto it." giving up after 60
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
			display alert "The Hugin app is not in the expected place. Please move it to the top level of the main Applications folder." giving up after 60
			error number -128
		else
			display alert "Oops" message errorNumber & ": " & errStr
		end if
	end try
	
	-- Check for parameters for enfuse from the user
	try
		repeat until paramValid is true
			set reply to display dialog "Enter any parameter strings you'd like to pass to enfuse:" & return & "(use simply " & quote & "--save-masks" & quote & "and app will automatically use the input-image folder as destination.)" default answer "" with title "enfuse parameters" buttons {"OK", "None"} default button "None"
			if not (button returned of reply is "None" or text returned of reply = "") then
				set paramString to the text returned of reply & "  " -- pad the reply to catch when the user pressed OK instead of None but entered no text
				if (characters 1 thru 2 of paramString as string ­ "--") or (length of paramString = 4) then
					--(display dialog) & characters 1 thru 2 of paramString = "--"
					try
						beep
						set reply to display alert "Invalid parameters" message "That does not appear to be a valid set of parameters." as warning buttons ["Never mind", "Try Again"] default button 2 giving up after 60
						if button returned of reply = "Never mind" or gave up of reply then error "nevermind"
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
	
	-- Fix --save-masks in paramString
	if paramString contains "--save-masks" then
		--display dialog "Yes!" & paramString
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "--save-masks "
		set temp to the text items of paramString
		--display dialog temp as string
		set AppleScript's text item delimiters to "--save-masks=" & "%d/%f-softmask.tif"
		set temp to the text items of temp
		--display dialog temp as string
		set paramString to temp as string
		--display dialog paramString
		set AppleScript's text item delimiters to tid
	end if
	
	
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
				set command to huginPosixPath & "align_image_stack -a " & newFileName & flist
				--display dialog command
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
						do shell script "mv " & newFileName & "[0-9][0-9][0-9][0-9].tif ~/.Trash"
					end tell
				on error errStr number errorNumber
					display alert "Error moving files to the trash" message errorNumber & ": " & errStr as string giving up after 60
				end try
			on error errStr number errorNumber
				display alert "Enfuse error" message errorNumber & ": " & errStr as string giving up after 60
			end try
		on error errStr number errorNumber
			display alert "Align error" message errorNumber & ": " & errStr as string giving up after 60
		end try
	end if
	
end open
