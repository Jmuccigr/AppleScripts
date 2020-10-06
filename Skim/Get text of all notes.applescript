-- Use Skim to extract notes from a PDF

tell application "Skim"
	set ready to false
	
	activate
	if (count of documents) = 0 then
		display alert "Nothing open" message "There's no active document!"
		error number -128
	end if
	
	-- Set some variables
	set t to ""
	set ct to 0
	--set action to "Revert"
	
	
	tell document 1
		(*
		if modified then
			set action to button returned of (display dialog "This document has already been modified." & return & "Should we leave it alone after reading the notes, or revert it to its last saved state?" buttons {"Cancel", "Revert", "Leave alone"} cancel button "Cancel" default button "Leave alone" with title "File modified" with icon caution)
		end if
		*)
		convert notes
		delay 1
		set ct to count of notes
		if ct = 0 then
			display alert "No notes!" message "There are no notes to extract. Exiting..."
			error -128
		end if
		-- Allow the user to enter a starting page number for the PDF. Make it 1 if no sensible input.
		set pageCount to (count of pages)
		repeat until ready
			try
				set coverPages to text returned of (display dialog "How many cover pages to the PDF?" & return & return & "(Cover pages are preceding pages we ignore for calculating the page numbers.)" with title "Cover pages?" default answer 1) as integer
				set startPage to text returned of (display dialog "What's the starting page number of the PDF, following the cover pages?" default answer 1) as integer
			on error errMsg number errNum
				if errNum = -128 then
					-- User canceled
					error number -128
				else
					-- Entered value wasn't a number
					set coverPages to 1 as integer
					set startPage to 1 as integer
				end if
			end try
			if coverPages < pageCount then
				set ready to true
			else
				display alert "Page count off!" message "The count of cover pages is higher than the total page count. Please try again."
			end if
		end repeat
		
		repeat with i from 1 to ct
			set n to (get text for note i) as string
			-- Assume that any end-of-line hyphens are broken words and not needed. (True more often than not.)
			set n to my replace(n, "-" & return, "")
			set n to my replace(n, "- ", "")
			set n to my replace(n, return, " ")
			--Calculate page nunmber & insert at end of quotation
			set p to (index of page of note i) + startPage - 1 - coverPages
			set t to t & "> " & n & " (p. " & p & ")"
			if i ­ ct then set t to t & return & return
		end repeat
		set the clipboard to t
		-- Undo convert notes operation, leaving document in its previous state
		tell application "System Events" to keystroke "z" using command down
		display notification "Notes extracted to the clipboard." with title "Success!" sound name "default"
	end tell
end tell

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
