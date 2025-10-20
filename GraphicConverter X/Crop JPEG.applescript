-- Script to use jpegtran to crop a jpeg with no recompression
-- Use GraphicConverter to select wanted area. jpegtran will crop as closely as possible
-- Not a lot of error checking

tell application "GraphicConverter 12"
	-- Make sure we're working on a jpeg
	try
		set fname to (the file of window 1)
	on error
		display alert "No file?" message "There doesn't appear to be a window open." giving up after 30
		error number -128
	end try
	
	tell application "Finder" to set ext to the name extension of file fname
	if ext is not in {"jpg", "JPG", "jpeg", "JPEG"} then
		display alert "Not JPEG" message "The file needs to be a jpeg for this script to work."
		error number -128
	end if
	set thePath to POSIX path of fname
	
	-- Now get the dimensions of the selection in the correct format
	-- GC provides the left x coord, the top y coord as distance from the bottom, the right x & upper y from bottom, plus overall dims
	tell window 1
		try
			set {xleft, ybottom, xright, ytop} to the selection
			set {imgW, imgH} to image dimension
		on error
			display alert "Problem" message "Is there anything selected?" giving up after 30
			error number -128
		end try
	end tell
	-- Convert GC's coords to what jpegtran wants
	set w to xright - xleft
	set h to ytop - ybottom
	set y1 to imgH - ytop
	set cropDims to (w & "x" & h & "+" & xleft & "+" & y1) as string
	
	-- Get info on the file to combine for path and name
	set dateString to (do shell script " date +%Y-%m-%d_%H.%M.%S")
	set newpath to (do shell script "dirname " & quoted form of thePath) & "/" & dateString & "_" & name of window 1
	
	-- Do it & preview result
	do shell script ("/opt/homebrew/bin/jpegtran -crop " & cropDims & " -outfile " & quoted form of newpath & " " & quoted form of thePath)
	do shell script ("qlmanage -p " & quoted form of newpath)
	
end tell
