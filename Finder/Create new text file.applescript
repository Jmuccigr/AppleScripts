tell application "Finder"
	set fname to (do shell script "date '+%Y%m%d-%H%M%S'") & ".txt"
	set newfile to (make new file at target of the front window as alias with properties {name:fname, file type:"TEXT"})
	select newFile
end tell