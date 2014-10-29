-- iPhoto Album-info Script
--
-- Developed by John Muccigrosso, modifying export script by Jonathan Block
-- jonblock@jonblock.com
-- Version 0.4 20 Oct 2014

-- The following checks to make sure the iPhoto is running.
-- Not needed because we use Spark to make sure it runs only from iPhoto
(*
set isRunning to false

tell application "System Events"
	set n to the name of every process
	--does not contain "iPhoto" then display alert "iPhoto is not running"
	repeat with i from 1 to number of items of n
		if item i of n is "iPhoto" then
			set isRunning to true
			exit repeat
		end if
	end repeat
end tell

if not isRunning then
	display alert "iPhoto is not running."
	error -128
end if
*)


tell application "iPhoto"
	set album_names to ""
	set theDate to ""
	set chosen_photos to {}
	set end_string to ""
	
	--activate
	try
		
		-- if photos are selected, use that selection
		copy (my selected_images()) to chosen_photos
		if chosen_photos = -1 then error number -128
		set photoCount to the number of items of chosen_photos
		if photoCount = 0 then
			display alert "No photos selected" message "You have to select at least one image." buttons {"OK"}
			error number -128
		end if
		repeat with i from 1 to photoCount
			set this_photo_id to item i of chosen_photos
			set album_names to (the name of every album whose id of the photos contains this_photo_id and type is regular album)
			set theDate to (the date of every photo whose id = this_photo_id)
			set theName to (the name of every photo whose id = this_photo_id)
			set old_delim to AppleScript's text item delimiters
			set AppleScript's text item delimiters to return & tab
			set album_names to album_names as string
			set AppleScript's text item delimiters to old_delim
			set album_count to the number of paragraphs of album_names
			if album_count > 1 then set end_string to "s"
			(*
repeat with a in album_list
			if the type of a is regular album then set album_names to album_names & return & the name of a
		end repeat
*)
			
			-- Report results
			if album_names = "" then
				display dialog (theDate as string) & return & return & "Sorry, this photo belongs to no albums." buttons {"OK"} default button 1
			else
				if i = photoCount then
					display dialog (theDate as string) & return & return & "Photo " & theName & " belongs to the following " & album_count & " album" & end_string & ":" & return & return & tab & album_names buttons {"OK"} default button 1
				else
					set theReply to display dialog (theDate as string) & return & return & "Photo " & theName & " belongs to the following " & album_count & " album" & end_string & ":" & return & return & tab & album_names buttons {"Cancel", "Next"} default button 2
					if the button returned of theReply = "Cancel" then exit repeat
				end if
			end if
		end repeat
		
	on error error_message number error_number
		if error_number ­ -128 then
			display alert error_number
			display alert error_message buttons {"OK"} giving up after 60
			display alert "ouch"
		end if
		--return "user cancelled"
	end try
end tell



on selected_images()
	tell application "iPhoto"
		try
			-- get selection
			set these_items to the selection
			set these_items_id to {}
			--			set these_items to item 1 of these_items
			-- check for single album selected
			if the class of item 1 of these_items is album then error "You have selected an album."
			if these_items = {} then error "You have not selected any photos."
			-- return the list of selected photos
			repeat with i in these_items
				--display dialog the id of i as string
				copy the id of i to the end of these_items_id --to these_items_id & the id of i --item  of these_items
				--display dialog these_items_id as string
				
			end repeat
			return these_items_id
		on error errMsg
			display alert "Error" message errMsg
			return -1
		end try
	end tell
end selected_images
