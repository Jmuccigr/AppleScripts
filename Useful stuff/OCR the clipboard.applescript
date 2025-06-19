-- Script to ocr image on the clipboard
-- Modified from https://stackoverflow.com/questions/19115078/applescript-clipboard-image-to-browse-directory

property fileTypes : {Â
	{GIF picture, ".gif"}, Â
	{JPEG picture, ".jpg"}, Â
	{TIFF picture, ".tiff"}}

set choices to {"eng", "deu", "fra", "ita", "grc", "lat"}
set tessdata to POSIX path of (path to documents folder) & "tessdata/"

-- Start the process by copying a section of the screen to the clipboard
--try
set theType to my getType()
try
	if theType is not missing value then
		set langs to (choose from list choices with prompt "What languages are in the image?" with multiple selections allowed)
		if langs is false then set langs to {"eng"}
		set TID to text item delimiters
		set text item delimiters to "+"
		set langstring to (langs as text) & " "
		set text item delimiters to TID
		set tempFile to (do shell script "echo $TMPDIR") & "clipboard_image" & (second item of theType as text)
		set myFile to (open for access tempFile with write permission)
		set eof myFile to 0
		write (the clipboard as (first item of theType)) to myFile -- as whatever
		close access myFile
		try
			do shell script "/opt/homebrew/bin/mogrify -colorspace Gray -normalize -bordercolor white -border 50x50 -units pixelsperinch -density 72 " & tempFile
		on error errMsg number errNum
			display alert "ImageMagick problem" message errNum & ": " & errMsg
		end try
		try
			set ocrtext to (do shell script ("/opt/homebrew/bin/tesseract --psm 6 -l " & langstring & " --tessdata-dir " & tessdata & " " & tempFile & " stdout 2>/dev/null | perl -0pe 's/^\\s*(.*)\\s*$/\\1/' "))
		on error errMsg number errNum
			display alert "tesseract problem" message (errNum & ": " & errMsg) as string
			error number -128
		end try
		if ocrtext ­ "" then
			set the clipboard to ocrtext
			display notification ("The image text is now on the clipboard:" & return & ocrtext) with title "Success!" sound name "beep"
		else
			error "The image on the clipboard does not appear to contain any text."
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
