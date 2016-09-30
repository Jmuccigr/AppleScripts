tell application "Google Earth Pro"
	set loc to GetViewInfo
	SetViewInfo {latitude:latitude of loc, longitude:longitude of loc, distance:(distance of loc) * 2, tilt:tilt of loc, azimuth:azimuth of loc} speed 1
end tell