-- Map lat, long points on the clipboard using google maps

on run
	set coords to (the clipboard)
	--- Convert textual degree to sign
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s*(deg)(ree)?/¡/g'")
	-- Get rid of leading and trailing non-numbers, with allowance for trailing E or W.
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/^[^0-9¡]+//' | perl -pe 's/[^0-9EW]+$//'")
	-- Get rid of internal spaces, leaving a single comma. Assume degree sign means there are spaces between units.
	if coords contains "¡" then
		-- First add a comma before the second coordinate with the degree sign
		set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s+(\\-*[0-9]+¡)/+\\1/g' | perl -pe 's/,\\+/+/'")
		-- Then get rid of all spaces
		set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s+//g'")
	else
		-- Any spaces should be between coordinates, so replace with comma
		set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s+(\\-*[0-9]+)/,\\1/g' | perl -pe 's/\\,\\,/,/'")
	end if
	--	set coords to (do shell script "echo " & coords & "'")
	--	Remove any third value, like an altitude, which Google apparently can't handle
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/(.+,.+),.*/\\1/' ")
	-- Open in the default browser
	set coords to my replace(coords, "'", "%27")
	set coords to my replace(coords, quote, "%22")
	set coords to my replace(coords, "¡", "%20")
	try
		open location ("http://www.google.com/maps/place/" & coords)
	on error
		display alert "error"
	end try
end run


-- Quick search and replace with TID
on replace(origtext, ftext, rtext)
	set tid to AppleScript's text item delimiters
	set newtext to origtext
	set AppleScript's text item delimiters to ftext
	set newtext to the text items of newtext
	set AppleScript's text item delimiters to rtext
	set newtext to the text items of newtext as string
	set AppleScript's text item delimiters to tid
	return newtext
end replace
