-- Inspired by Dr. Drang's python script here:
-- http://www.leancrew.com/all-this/2012/11/markdown-table-scripts-for-bbedit/
-- which takes tab-separated text and turns it into a markdown table.
-- Currently written to work in apps without AS support (like MacDown).
-- Can easily be adopted to use as a service.

-- First get the selected text by copying it.
tell application "System Events" to keystroke "c" using command down
set thetext to the clipboard
set deleteCount to 0
set terminalReturn to ""

if the last item of thetext is return then
	set deleteCount to 1
	repeat with i from 0 to deleteCount
		set terminalReturn to return
	end repeat
end if

-- Now convert it
set temp to ""

-- Prefix and suffix lines with a pipe & convert tabs to pipes
try
	repeat with i from 1 to the (number of paragraphs of thetext) - deleteCount
		set temp to temp & "|" & paragraph i of thetext & "|" & return
	end repeat
	set temp to replace(temp, tab, "|")
on error errMsg
	set the clipboard to errMsg
	display dialog "Problem adding pipes"
end try

-- Add a header line which assumes that the first line has the correct number of columns
set theNewText to paragraph 1 of temp & return & createHeader(thetext)
repeat with i from 2 to the (count of paragraphs of temp)
	set theNewText to theNewText & return & paragraph i of temp
end repeat

-- Paste it in, which is faster than keystroking it
set the clipboard to theNewText & terminalReturn
tell application "System Events" to keystroke "v" using command down


on createHeader(t)
	set hline to ""
	set t to paragraph 1 of t
	repeat with i from 1 to (countchar(t, tab) + 1)
		set hline to hline & "|---"
	end repeat
	set hline to hline & "|"
	return hline
end createHeader

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

-- Count characters in a text
on countchar(origtext, ch)
	set {oldtids, my text item delimiters} to {my text item delimiters, ch}
	set keyCount to (count text items of origtext) - 1
	set my text item delimiters to oldtids
	return keyCount
end countchar
