-- Short script to read what's on the clipboard at a reasonable rate.
-- Slow it down by holding down the option key on start-up.
-- Speed it up with the command key.

# First set the delay speek between paragraphs
set pause to 0.5

tell application "Finder"
	set theText to the clipboard
	repeat with p in paragraphs of theText
		say p
		delay pause
	end repeat
end tell

