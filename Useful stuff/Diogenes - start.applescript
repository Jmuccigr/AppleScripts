tell application "Finder"
	
	set homedir to POSIX path of (path to documents folder) & "Academic/PHI stuff/"
	
	if (name of every disk as list) does not contain "TLG_E" then
		do shell script ("hdiutil attach " & quoted form of (homedir & "TLG Greek.dmg") & " -mount required &")
	end if
	if (name of every disk as list) does not contain "PHI0005" then
		do shell script ("hdiutil attach " & quoted form of (homedir & "PHI Latin.dmg") & " -mount required")
	end if
	
	-- Wait until the Greek disk is mounted. It's bigger and starts second.
	-- Really could do better checking on this.
	set timer to 0
	repeat until (name of every disk as list) contains "TLG_E"
		delay 1
		set timer to timer + 1
		if timer ³ 60 then
			display dialog "It's been a minute and the Greek disk still hasn't mounted. Quitting now..."
			quit
		end if
	end repeat
	
	-- Diogenes seems to need to be told to activate twice to make sure a window opens
	repeat with i in {1, 2}
		tell application "Diogenes" to activate
	end repeat
	
	-- Leftover from old Finder method of mounting disks which left open windows
	delay 5
	if window named "PHI0005" exists then close window named "PHI0005"
	if window named "TLG_E" exists then close window named "TLG_E"
	
end tell

