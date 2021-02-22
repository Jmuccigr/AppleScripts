tell application "Photos"
	set selectedphoto to the selection
	-- Make sure a photo is actually selected
	if selectedphoto is {} then
		display alert "No photos selected" message "You need to select a single photo."
		return
	end if
	-- Select photo itself for info retrieval
	set firstPhoto to item 1 of selectedphoto
	set fname to the filename of firstPhoto
	set exportFolder to (choose folder with prompt "Export as File" default location path to downloads folder) as text
	-- But export wants a list
	export selectedphoto to (exportFolder & fname) with using originals
end tell