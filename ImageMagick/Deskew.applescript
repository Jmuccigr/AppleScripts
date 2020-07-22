-- Deskew images using imagemagick

on open of finderObjects
	set ct to the count of finderObjects
	set amount to "40%"
	
	repeat with filename in (finderObjects)
		set fname to quoted form of POSIX path of filename
		do shell script "/usr/local/bin/magick " & fname & " +repage -deskew " & amount & " +repage $TMPDIR/tempfile.png"
		tell application "Finder"
			delete file filename
			do shell script "cp $TMPDIR/tempfile.png " & fname
			if ct < 4 then
				do shell script "qlmanage -p " & fname
			end if
			select file filename
		end tell
	end repeat
end open
