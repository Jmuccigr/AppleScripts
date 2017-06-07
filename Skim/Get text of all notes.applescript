-- Use Skim to extract notes from a PDF

tell application "Skim"
	if (count of documents) = 0 then
		display alert "Nothing open" message "There's no active document!"
		error number -128
	end if
	
	-- Set some variables
	set t to ""
	--set action to "Revert"
	
	-- Allow the user to enter a starting page number for the PDF. Make it 1 if no sensible input.
	try
		set startPage to text returned of (display dialog "What's the starting page number of the PDF?" & return & return & "(Don't forget to account for any cover pages!)" with title "Starting page?" default answer 1) as integer
	on error errMsg number errNum
		if errNum = -128 then
			-- User canceled
			error number -128
		else
			-- Entered value wasn't a number
			set startPage to 1 as integer
		end if
	end try
	
	tell document 1
		(*
		if modified then
			set action to button returned of (display dialog "This document has already been modified." & return & "Should we leave it alone after reading the notes, or revert it to its last saved state?" buttons {"Cancel", "Revert", "Leave alone"} cancel button "Cancel" default button "Leave alone" with title "File modified" with icon caution)
		end if
*)
		convert notes
		set ct to count of notes
		repeat with i from 1 to ct
			set n to (get text for note i) as string
			set n to my replace(n, return, " ")
			set p to (index of page of note i) + startPage - 1
			set t to t & "> " & n & " (p. " & p & ")"
			if i ­ ct then set t to t & return & return
		end repeat
		set the clipboard to t
		-- Undo convert notes operation, leaving document in its previous state
		tell application "System Events" to keystroke "z" using command down
		(*
		if action = "Revert" then
			--revert
		end if
*)
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
