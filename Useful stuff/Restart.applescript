-- Simple script to restart the frontmost app

tell application "System Events"
	set appname to the name of (process 1 where frontmost is true)
end tell
tell application appname to quit
--to quit
set listOfProcesses to {}
tell application "System Events"
	repeat until listOfProcesses does not contain appname
		set listOfProcesses to (name of every process where background only is false)
		delay 1
	end repeat
	delay 1
end tell
tell application appname to activate
