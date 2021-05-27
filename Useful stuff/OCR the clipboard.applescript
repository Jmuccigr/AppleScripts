-- Script to ocr image on the clipboard
-- Modified from https://stackoverflow.com/questions/19115078/applescript-clipboard-image-to-browse-directory

property fileTypes : {Â
	{JPEG picture, ".jpg"}, Â
	{TIFF picture, ".tiff"}, Â
	{GIF picture, ".gif"}}

-- Stat the process to copy a section of the screen to the clipboard
try
	set theType to my getType()
	
	if theType is not missing value then
		set tempFile to (do shell script "echo $TMPDIR") & "clipboard_image" & (second item of theType as text)
		set myFile to (open for access tempFile with write permission)
		set eof myFile to 0
		write (the clipboard as (first item of theType)) to myFile -- as whatever
		close access myFile
		set ocrtext to do shell script ("/usr/local/bin/tesseract " & tempFile & " stdout 2>/dev/null | perl -0pe 's/^\\s*(.*)\\s*$/\\1/' ")
		--		display dialog ">" & ocrtext & "<" & return & (count of items of ocrtext)
		if ocrtext ­ "" then
			set the clipboard to ocrtext
			display notification ("The image text is now on the clipboard.") with title "Success!" sound name "beep"
		else
			error "The clipboard does not appear to contain an image with text."
		end if
	end if
on error errMsg
	try
		close access myFile
	end try
	display alert "Oops" message errMsg giving up after 15
end try

on getType()
	repeat with aType in fileTypes -- find the first match in the list
		repeat with theInfo in (clipboard info)
			if (first item of theInfo) is equal to (first item of aType) then return aType
		end repeat
	end repeat
	error "The clipboard does not appear to contain an image."
end getType
