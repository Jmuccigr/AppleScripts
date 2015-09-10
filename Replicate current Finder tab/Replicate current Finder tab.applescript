tell application "Finder"
	set theTarget to the target of the front window
	tell application "System Events" to keystroke "t" using command down
	set the target of the front window to theTarget
end tell