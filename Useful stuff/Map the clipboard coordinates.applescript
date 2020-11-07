-- Map lat, long points on the clipboard using google maps

on run
	set coords to (the clipboard)
	-- Get rid of leading and trailing non-numbers, with allowance for trailing E or W.
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/^[^0-9¡]+//' | perl -pe 's/[^0-9EW]+$//'")
	-- Get rid of internal spaces, leaving a single comma.
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s+/,/g' | perl -pe 's/\\,+/,/' | perl -pe 's/,$//'")
	--	set coords to (do shell script "echo " & coords & "'")
	--	Remove any third value, like an altitude, which Google apparently can't handle
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/(.+,.+),.*/\\1/' ")
	-- Open in the default browser
	open location ("http://www.google.com/maps/place/" & coords)
end run