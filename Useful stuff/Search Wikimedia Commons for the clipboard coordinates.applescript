-- Search Wikimedia Commons for images near lat, long points on the clipboard
-- See https://www.mediawiki.org/wiki/API:FAQ for more info

on run
	-- Set some variables
	set maxRadius to "5000"
	set radius to ""
	set format to "jsonfm"
	set limit to "100"
	
	-- Get radius in m to search around point
	repeat until (radius as number > 0)
		set radiusReply to (display dialog "Enter a value for the number of meters to search around the given point. Anything greater than the maximum allowed radius of " & maxRadius & "m will be reduced to that maximum." with title "Choose a radius" default answer maxRadius)
		set radius to text returned of radiusReply
		try
			set radius to radius as number
			if radius = 0 then error 9999
		on error
			display alert "Numbers only" message "You must enter a number for the radius."
			set radius to ""
		end try
	end repeat
	if (radius as number > 5000) then set radius to maxRadius

	set coords to (the clipboard)
	-- Get rid of leading and trailing non-numbers, with allowance for trailing E or W.
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/^[^0-9¡]+//' | perl -pe 's/[^0-9EW]+$//'")
	-- Get rid of internal spaces, leaving a single pipe.
	set coords to (do shell script "echo " & quoted form of coords & " | perl -pe 's/\\s+/,/g' | perl -pe 's/\\,+/|/' | perl -pe 's/,$//'")
	--	set coords to (do shell script "echo " & coords & "'")
	try
		tell application "Safari"
			-- Get images with links to files
			open location "https://commons.wikimedia.org/w/api.php?format=" & format & "&ggslimit=" & limit & "&action=query&generator=geosearch&ggsprimary=all&ggsnamespace=6&ggsradius=" & radius & "&ggscoord=" & coords & "&prop=imageinfo&iiprop=url&iiurlwidth=200&iiurlheight=200"
			--Get image names
			--open location "https://commons.wikimedia.org/w/api.php?format=jsonfm&action=query&list=geosearch&gsprimary=all&gsnamespace=6&gsradius=" & radius & "&gscoord=" & coords
			activate
		end tell
	on error errMsg number errNum
		display alert "Error" message errNum & ": " & errMsg
	end try
end run