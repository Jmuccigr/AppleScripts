-- An app to switch to Mail if it's already running or
-- to start it and check for the QuoteFix plugin if it isn't.

on run
	set quotefix to false
	tell application "System Events"
		if the name of (every process where background only is false) does not contain "Mail" then
			tell application "Mail"
				activate
				set quotefix to my do_submenu("Mail", "Mail", "QuoteFix is enabled")
				if not quotefix then
					set openPref to button returned of (display dialog "QuoteFix is not running. Open Preferences?" buttons {"Yes", "No"} default button 1 with title "No QuoteFix")
					if openPref = "Yes" then
						tell application "System Events" to keystroke "," using command down
					end if
				end if
			end tell
		else
			tell application "Mail" to activate
		end if
	end tell
end run

on do_submenu(app_name, menu_name, menu_item)
	try
		-- bring the target application to the front
		tell application app_name
			activate
		end tell
		tell application "System Events"
			tell process app_name
				tell menu bar 1
					tell menu bar item menu_name
						tell menu menu_name
							tell menu item menu_item
								properties
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
		return true
	on error error_message
		return false
	end try
end do_submenu