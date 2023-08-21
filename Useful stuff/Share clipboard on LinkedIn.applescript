global python_path

on run
	set python_path to (do shell script "which python3")
	
	set input to the clipboard as string
	set l to the number of characters of input
	if l > 30 then set l to 30
	-- Make sure clipboard looks like a URL
	if characters 1 thru 4 of input is not "http" then
		set theReply to button returned of (display dialog "The clipboard doesn't look like it contains a URI. Want to prepend \"http\" and try it anyway?" & return & return & "The clipboard starts: " & return & (characters 1 thru l of input) with title "Not a URI" buttons {"Yes", "No"} default button 2)
		if theReply = "Yes" then
			set input to "http://" & input
		else
			error number -128
		end if
	end if
	open location "https://www.linkedin.com/sharing/share-offsite/?url=" & my url_encode(input)
end run

on url_encode(input)
	return (do shell script "echo " & input & " | " & python_path & " -c \"import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))\"  | sed 's/%0A$//'")
end url_encode
