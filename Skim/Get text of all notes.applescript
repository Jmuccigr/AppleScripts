-- Use Skim to extract notes with relative page numbers

tell application "Skim"
	set t to ""
	tell document 1
		convert notes
		set ct to count of notes
		repeat with i from 1 to ct
			set n to (get text for note i) as string
			set n to my replace(n, return, " ")
			set p to index of page of note i
			set t to t & "> " & n & " (p. " & p & ")"
			if i ­ ct then set t to t & return & return
		end repeat
		set the clipboard to t
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
