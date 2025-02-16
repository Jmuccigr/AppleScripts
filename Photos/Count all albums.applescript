global acount, mcount2


tell application "Photos"
	set mcount2 to 0
	set acount to (count of albums)
	repeat with fol in folders
		my countAlbums(fol)
	end repeat
	acount & return & mcount2
end tell

on countAlbums(f)
	global acount, mcount2
	
	using terms from application "Photos"
		if name of f is not "_Smart albums" then -- Need to skip what can be large smart albums
			tell f
				try
					set acount to acount + (count of albums)
					set mcount2 to mcount2 + (count of media items of every album)
					--repeat with a in albums
					--	set mcount2 to mcount2 + (count of media items of a)
					--end repeat
					repeat with fol in folders
						my countAlbums(fol)
					end repeat
				on error errMsg number errNum
					display alert "Error" message errMsg
					error number -128
				end try
			end tell
		end if
	end using terms from
end countAlbums