on run
	set coords to (the clipboard)
	-- Get rid of leading and trailing non-numbers.
	set coords to (do shell script "echo " & coords & " | perl -pe 's/^[^0-9]+//' | perl -pe 's/[^0-9]+$//'")
	-- Get rid of internal spaces, leaving a single comma.
	set coords to (do shell script "echo " & coords & " | perl -pe 's/\\s+/,/g' | perl -pe 's/\\,+/,/' | perl -pe 's/,$//'")
	--	set coords to (do shell script "echo " & coords & "'")
	
	tell application "Safari" to open location ("http://www.google.com/maps/place/" & coords)
end run
