tell application "Diogenes" to quit
tell application "Finder"
	set otherDisks to {"PHI0005", "TLG_E"}
	repeat with myDisk in otherDisks
		try
			eject myDisk
		end try
	end repeat
end tell
