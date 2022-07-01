-- A script to use exiftool to set the three bit date fields of a photo to the same date.
-- exiftool needs a month and day, so these will be set to January and the 1st if nothing valid is entered.
-- exiftool needs a time, too, so it will be set to noon if nothing valid is entered.
-- Error checking is pretty minimal.


on open photoList
	set now to the year of the (current date)
	set monthList to {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
	set dateProblem to ""
	repeat with photo in photoList
		tell application "System Events" to set fName to (name of photo) as string
		set yearSet to false
		set mNum to 1
		set dNum to 1
		set fPath to (the POSIX path of photo)
		repeat until yearSet is true
			-- Get year. This is the only thing that needs to be set
			set y to text returned of (display dialog fName & return & return & dateProblem & "Enter a year after 1900:" with title "Year" default answer "1980")
			set yNum to y as integer
			if yNum > 1900 and yNum < (now + 1) then
				set yearSet to true
			else
				set dateProblem to "Entered year is out of range. "
			end if
			-- Get month & convert to number
			set m to (choose from list monthList with title "Month" with prompt "Choose the month" default items "" with empty selection allowed without multiple selections allowed)
			if (count of m) > 0 then
				repeat with i from 1 to 12
					if item 1 of m = item i of monthList then
						set mNum to i
						exit repeat
					end if
				end repeat
			end if
			-- Get day
			set d to text returned of (display dialog "Enter a day of the month" with title "Day" default answer "")
			try
				set dNum to d as integer
			on error
				set dNum to 1
			end try
			if (dNum < 1 or dNum > 31) then set dNum to 1
			-- Get time
			set tNum to text returned of (display dialog "Enter a valid 24-hour time" with title "Time" default answer "12:00:00")
			set tNum to (do shell script "echo " & tNum & " | sed 's/[^0-9:]//g'")
			if tNum is "" or the first item of tNum is not in "1234567890" then set tNum to "12:00:00"
			try
				do shell script ("/usr/local/bin/exiftool " & quote & "-AllDates=" & yNum & ":" & mNum & ":" & dNum & space & tNum & quote & space & fPath)
			on error errMsg number errNum
				display alert "Error!" message (errNum & ": " & errMsg as string)
			end try
		end repeat
	end repeat
end open