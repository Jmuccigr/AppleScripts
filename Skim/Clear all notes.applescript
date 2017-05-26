-- Use Skim to clear notes

tell application "Skim"
	tell document 1
		convert notes
		set ct to count of notes
		delete notes
		display alert ct & " notes were deleted."
	end tell
end tell
