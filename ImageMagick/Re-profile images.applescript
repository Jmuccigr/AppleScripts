-- Set a series of iPhone images so that they all have color profiles.
-- Use the profile from one of the images for the others that have none.
-- This works best when you have a set from the same sequence of photos.

property iPhoneImageFiles : {}

on open dropped_files
	set iPhoneImageFiles to iPhoneImageFiles & dropped_files
end open

on quit
	set ct to the count of iPhoneImageFiles
	if ct = 1 then
		display alert "No point!" message "This process requires more than one file to work on." as critical giving up after 30
		error number -128
	end if
	set foundProfile to false
	set fixList to {}
	set profileList to {}
	repeat with imageFile in (iPhoneImageFiles)
		tell application "Image Events"
			set i to open imageFile
			try
				set prof to the name of the embedded profile of i
				set profileList to profileList & imageFile
				set foundProfile to true
			on error
				set prof to ""
				set fixList to fixList & imageFile
			end try
		end tell
	end repeat
	if (count of fixList) = 0 then
		display alert "All good!" message "There are no files missing profiles." as critical giving up after 30
	else
		if foundProfile then
			set ct to the count of profileList
			if ct > 1 then
				set profilePick to choose from list profileList with prompt "Select the file whose profile you want to use:"
			else
				set profilePick to item 1 of profileList
			end if
			set profilePick to the quoted form of the POSIX path of profilePick
			try
				do shell script ("/usr/local/bin/magick " & profilePick & " $TMPDIR/profile.icc")
			on error errMsg number errNum
				display alert "Problem with imagemagick getting profile" message (errNum as string) & ": " & errMsg
				error number -128
			end try
			repeat with imageFile in fixList
				set filename to the quoted form of the POSIX path of imageFile
				try
					do shell script ("/usr/local/bin/magick mogrify" & " -profile $TMPDIR/profile.icc " & filename)
				on error errMsg number errNum
					display alert "Problem with imagemagick writing profile" message (errNum as string) & ": " & errMsg
					error number -128
				end try
			end repeat
			display notification "Your images now all have a profile." with title "Profiling complete" sound name "default"
		else
			beep
			display alert "No profile!" message "None of these images has an embedded profile to use." as critical giving up after 30
		end if
	end if
	
	set iPhoneImageFiles to {}
	continue quit
end quit
