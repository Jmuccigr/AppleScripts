on run
	tell application "MacDown" to activate
	set theNewText to ""
	set theScript to "
#!/usr/bin/local/python

import sys
import subprocess

def getClipboardData():
 p = subprocess.Popen(['pbpaste'], stdout=subprocess.PIPE)
 retcode = p.wait()
 data = p.stdout.read()
 return data

def just(string, type, n):
    " & quote & "Justify a string to length n according to type." & quote & "

    string = unicode(string, 'utf-8')

    if type == '::':
        return string.center(n)
    elif type == '-:':
        return string.rjust(n)
    elif type == ':-':
        return string.ljust(n)
    else:
        return string


def normtable(text):
    " & quote & "Aligns the vertical bars in a text table." & quote & "

    # Start by turning the text into a list of lines.
    lines = text.splitlines()
    rows = len(lines)

    # Figure out the cell formatting.
    # First, find the separator line.
    for i in range(rows):
        if set(lines[i]).issubset('|:.-'):
            formatline = lines[i]
            formatrow = i
            break

    # Delete the separator line from the content.
    del lines[formatrow]

    # Determine how each column is to be justified.
    formatline = formatline.strip(' ')
    if formatline[0] == '|': formatline = formatline[1:]
    if formatline[-1] == '|': formatline = formatline[:-1]
    fstrings = formatline.split('|')
    justify = []
    for cell in fstrings:
        ends = cell[0] + cell[-1]
        if ends == '::':
            justify.append('::')
        elif ends == '-:':
            justify.append('-:')
        else:
            justify.append(':-')

    # Assume the number of columns in the separator line is the number
    # for the entire table.
    columns = len(justify)

    # Extract the content into a matrix.
    content = []
    for line in lines:
        line = line.strip(' ')
        if line[0] == '|': line = line[1:]
        if line[-1] == '|': line = line[:-1]
        cells = line.split('|')
        # Put exactly one space at each end as " & quote & "bumpers." & quote & "
        linecontent = [ ' ' + x.strip() + ' ' for x in cells ]
        content.append(linecontent)

    # Append cells to rows that don't have enough.
    rows = len(content)
    for i in range(rows):
        while len(content[i]) < columns:
            content[i].append('')

    # Get the width of the content in each column. The minimum width will
    # be 2, because that's the shortest length of a formatting string and
    # because that matches an empty column with " & quote & "bumper" & quote & " spaces.
    widths = [2] * columns
    for row in content:
        for i in range(columns):
        widths[i] = max(len(row[i].decode(" & quote & "utf-8" & quote & ")), widths[i])

    # Add whitespace to make all the columns the same width and
    formatted = []
    for row in content:
        formatted.append('|' + '|'.join([ just(s, t, n) for (s, t, n) in zip(row, justify, widths) ]) + '|')

    # Recreate the format line with the appropriate column widths.
    formatline = '|' + '|'.join([ s[0] + '-'*(n-2) + s[-1] for (s, n) in zip(justify, widths) ]) + '|'

    # Insert the formatline back into the table.
    formatted.insert(formatrow, formatline)

    # Return the formatted table.
    return '\\n'.join(formatted)


# Read the input, process, and print.
#unformatted = sys.stdin.read()
#unformatted = sys.stdin.read() #getClipboardData()
print normtable(unformatted).encode('utf-8')"
	
	tell application "System Events"
		keystroke "c" using command down
		try
			--set the clipboard to (do shell script "python /Users/john_muccigrosso/Library/Application\\ Support/BBEdit/Unix\\ Support/Unix\\ Scripts/Normalize\\ Table.py")
			set the clipboard to (do shell script "python -c '" & theScript & "'")
			keystroke "v" using command down
		on error errmsg
			set the clipboard to errmsg
			display alert "Oops" message errmsg
		end try
	end tell
end run