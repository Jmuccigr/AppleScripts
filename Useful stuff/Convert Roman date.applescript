-- A script to convert a Roman-style date to a modern style.
-- It accounts for the Julian/Gregorian differences.
-- Not much error-checking at this point, so you can try a nonsensical "43 kal Mar".
-- Assumes input is in form "[days-before] named-day month year",
-- where named-day is at least first letter of kalends, nones, and ides;
-- month is at least the first three letters of the month name in Latin or English
-- (i.e., "May" and "Mai" are both good); and year is the year in the modern system.
-- It's just doing a name change, not trying to find astronomical equivalents.
-- Given a year, it will also provide the day of the week.

global mList, mLength
on run
	
	set mList to {"jan", "feb", "mar", "apr", "mai", "jun", "jul", "aug", "sep", "oct", "nov", "dec"}
	set mLength to {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	set warn to ""
	set y to 2999
	set leapyear to false
	
	set input to "4 kal jan 156"
	
	set datestring to (do shell script "echo " & input & " | tr  '[:upper:]' '[:lower:]'")
	
	set wordCt to number of words of datestring
	set l to number of characters of datestring
	if wordCt < 2 or l < 5 then
		display alert "Invalid string" message "The date string appears to be too short."
		error number -128
	end if
	
	-- First handle the dates on a named day
	if wordCt = 2 then
		-- We have just named day and month
		set d to 0
		set namedDay to word 1 of datestring
		set mon to word 2 of datestring
		set off to 0
	else
		-- Then set it up for other scenarios
		-- 3rd arg is year, so we have named day - month - year
		try
			(word 3 of datestring) as integer = word 3 of datestring
			set d to 0
			set namedDay to word 1 of datestring
			set mon to word 2 of datestring
			set off to 0
			set y to word 3 of datestring as integer
		on error
			-- 3rd arg is NOT year, so day - named day - month
			set d to word 1 of datestring
			set namedDay to word 2 of datestring
			set mon to word 3 of datestring
			set off to my getDayCount(d)
			try
				-- Check 4th item for year
				(word 4 of datestring) as integer = word 4 of datestring
				set y to word 4 of datestring as integer
			on error
				-- Otherwise it's not a year, so do nothing with it
			end try
		end try
	end if
	
	-- Identify leapyears
	if y > 1582 then
		-- Gregorian calendar
		if (y mod 4 = 0) and (y mod 100 = 0) and (y mod 400 ­ 0) then set leapyear to true
	else
		-- Julian calendar
		if (y mod 4 = 0) then set leapyear to true
	end if
	
	-- Convert month to a number
	set m to my getMonthNumber(mon)
	
	-- Convert named day to a day of the month (number)
	set namedDay to my getNamedDay(namedDay)
	
	-- Correct year, month, and day for kalends
	--display dialog "off: " & off
	if namedDay = 1 and off > 0 then
		if m = 1 then set y to y - 1
		set m to m - 1
		if m = 0 then set m to 12
		set namedDay to (item m of mLength) + 1
		--display dialog namedDay
		if leapyear and m = 2 then set namedDay to 30
		--display dialog namedDay
	end if
	
	set finalDay to namedDay - off
	
	-- Display date in nice format. Use 2999 (=y) because it's not a leap year.
	-- Warn if there's no year given and the date is in late February
	if m = 2 and namedDay > 13 then set warn to "In leap years, add one to this date."
	set dstring to (m & "/" & finalDay & "/" & y) as string
	-- display dialog dstring
	set outputM to month of date dstring as string
	-- display dialog "outputD: " & outputD
	set displayString to warn & return & outputM & space & finalDay
	if y < 2999 then
		set displayString to (displayString & ", " & the year of date dstring as string) & " (" & (the weekday of date dstring as string) & ")"
		display dialog date string of (date dstring)
	else
		display dialog displayString
	end if
end run

-- Sub-routines

on getDayCount(d)
	-- Get number from start of datestring
	if character 1 of d is "p" then
		set d to 2
	else
		try
			set d to d as integer
		on error
			-- assume the number is a Roman numeral
			set d to my romanToInt(d)
		end try
	end if
	-- display dialog "day: " & d - 1
	return d - 1
end getDayCount


on getNamedDay(d)
	set d to character 1 of d as string
	if d is not in {"k", "n", "i"} then
		display alert "Invalid named day" message "The named day in the date string appears to be invalid."
		error number -128
	end if
	set val to 1
	if d = "i" then
		set val to 13
	else
		if d = "n" then
			set val to 5
		end if
	end if
	--display dialog "named day: " & val
	-- Correct for the full months
	if val > 1 and m is in {3, 5, 7, 10} then set val to val + 2
end getNamedDay


on getMonthNumber(m)
	try
		set m to characters 1 through 3 of m as string
		set m to (do shell script "echo " & m & " | tr '[:upper:]' '[:lower:]'") as string
		set m to (do shell script "echo " & m & " | tr 'y' 'i' ") as string
	on error
		display alert "Not a month" message "Date does not contain a month name."
		error number -128
	end try
	set mNumber to 0
	set i to 1
	if mList contains m then
		repeat with i from 1 to 12
			if item i of mList = m then
				--display dialog "month: " & i
				return i
				exit repeat
			end if
		end repeat
	else
		display alert "Not a month" message "Date does not contain a month name."
		error number -128
	end if
end getMonthNumber

-- The next bit from https://gist.github.com/jpcranford/35098d7d201c33a673cec11bb46efbe3
on romanToInt(numeral)
	set numeral to (do shell script "echo " & numeral & " | tr '[:lower:]' '[:upper:]'")
	set n to 0
	try
		repeat while numeral is not ""
			if numeral starts with "M" then
				set n to n + 1000
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "CM" then
				set n to n + 900
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "D" then
				set n to n + 500
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "CD" then
				set n to n + 400
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "C" then
				set n to n + 100
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "XC" then
				set n to n + 90
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "L" then
				set n to n + 50
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "XL" then
				set n to n + 40
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "X" then
				set n to n + 10
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "IX" then
				set n to n + 9
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "V" then
				set n to n + 5
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else if numeral starts with "IV" then
				set n to n + 4
				set numeral to characters 3 thru (length of numeral) of numeral as string
			else if numeral starts with "I" then
				set n to n + 1
				set numeral to characters 2 thru (length of numeral) of numeral as string
			else
				display alert "No number" message "This string does not start with a number."
				error number -128
			end if
		end repeat
	end try
	return n
end romanToInt
