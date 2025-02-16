-- Script to create a composite image file from the files dropped on it.

on open finderObjects
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set myDownloads to POSIX path of (path to downloads folder)
	set tempdir to (do shell script "echo $TMPDIR")
	set destmpc to " " & tempdir & "destination.mpc "
	set tiff to " "
	
	-- Grab the image type of the first file to use for the output image
	tell application "Finder" to set ext to the name extension of file (item 1 of finderObjects)
	-- tiff compression gets preserved
	if ext contains "tif" then set tiff to " -define tiff:preserve-compression=true "
	
	-- First make a file to start with, then loop through all the files
	do shell script "/opt/homebrew/bin/magick " & (the quoted form of the POSIX path of (item 1 of finderObjects)) & " $TMPDIR/destination.mpc"
	repeat with f in finderObjects
		set fp to the quoted form of (the POSIX path of f)
		do shell script "/opt/homebrew/bin/magick" & tiff & "-compose multiply " & fp & destmpc & "-composite" & destmpc
	end repeat
	
	-- Save the final product to the Downloads folder
	do shell script "/opt/homebrew/bin/magick" & tiff & destmpc & myDownloads & dateString & "composite." & ext
	
	tell application "Finder" to open myDownloads as POSIX file
	display notification ("Composite file now in the Downloads folder.") with title "All done!" sound name "beep"
end open