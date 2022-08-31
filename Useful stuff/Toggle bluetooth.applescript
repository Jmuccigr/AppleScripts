set blueutilcmd to "/opt/homebrew/bin/blueutil"
set sb to last word of paragraph 1 of (do shell script blueutilcmd)
if sb is "1" then
	do shell script blueutilcmd & " --power 0"
	display notification "Bluetooth is now off!" sound name "chime"
else
	do shell script blueutilcmd & " --power 1"
	display notification "Bluetooth is now on!" sound name "chime"
end if
