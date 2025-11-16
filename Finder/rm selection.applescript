tell application "System Events"
	set activeApp to (name of (process 1 where frontmost is true) as string)
end tell
if activeApp is "Finder" then
	tell application "Finder"
		set tmpdir to (do shell script "echo $TMPDIR") & "delete_tonight/"
		set tmpdir to (POSIX file tmpdir) as alias
		move the selection to tmpdir with replacing
	end tell
end if