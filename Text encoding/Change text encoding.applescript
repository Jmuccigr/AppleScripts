-- Script to convert text files to UTF-8 from whatever other encoding they're in.
-- Written because WritePad on the iPad saves as UTF-16LE, which isn't good for markdown

set toEnc to "utf-8"

set theDir to (path to home folder as string) & "DropBox:WritePad:"
tell application "Finder" to get the document files of alias theDir
set i to the result

repeat with j in i
	-- First look at only files with a txt extension
	if (name extension of j) as string is "txt" then
		set thePlainFile to the POSIX path of (j as alias)
		set theFile to the quoted form of thePlainFile
		set theEncoding to (do shell script "file -bI " & theFile)
		-- Then as long as the encoding is appropriate, convert it, saving the original with new extension tied to the time
		-- NB No error checking here. Existing file with same name will get blown away (however unlikely).
		if the first word of theEncoding is "text" then
			set tid to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "="
			set theEncoding to the last text item of theEncoding
			set AppleScript's text item delimiters to tid
			if theEncoding is not "us-ascii" and theEncoding is not "utf-8" then
				set ext to "." & the time of the (current date) as string
				set newName to the quoted form of (thePlainFile & ext)
				do shell script ("mv " & the quoted form of thePlainFile & " " & newName)
				do shell script ("iconv -f " & theEncoding & " -t " & toEnc & " " & newName & " > " & theFile)
			end if
		end if
	end if
end repeat