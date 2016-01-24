# Some useful scripts for working with markdown.

* Convert to table
   * This takes a tab-separated bit of text and turns it into a md table with pipes. It's basically a translation into AppleScript of [Dr. Drang's perl script](http://www.leancrew.com/all-this/2012/11/markdown-table-scripts-for-bbedit/) (which is of course much more economical). I use it in ~/Library/Scripts/Applications/MacDown, the last of which is my markdown editor. It's easily converted into a Service, if you prefer it that way.

* Normalize table
	* Adds spaces to markdown table to make it visually more appealing. It uses AppleScript to run the [revised-for-Unicode version](http://www.leancrew.com/all-this/2012/03/improved-markdown-table-commands-for-textmate/) of Dr. Drang's [python script](http://www.leancrew.com/all-this/2012/11/markdown-table-scripts-for-bbedit/).