# Useful stuff

Like it sounds.

- "U to V" converts Latin text with only U/u to correct forms with V. Will also work with text that has just V/v.
- "Snippets" contains useful bits to use in longer scripts.
- "Toggle Bluetooth" turns Bluetooth on and off with a notification.
- "Move app windows" moves the windows of a few apps when there's more than one display in use, since they can't remember how to do this themselves.
- "Touch selection" executes shell `touch` command on Finder selection.
- "PDF page numbers" puts page numbers onto existing pages of a PDF. Basic put handy. Puts the number pretty low at the bottom to avoid existing material. Assumes the presence of pdftk, pdfinfo, and pdflatex.
- "Filter PDF" removes one or more PDF layers: text, raster or vector images. The first helps in cases of poor OCR <cough>JSTOR<cough>; the last for watermarks or other repeating vector images on each page. Assumes Ghostscript is installed.
- "Map the clipboard coordinates": assumes the clipboard has two numbers on it for long and lat, then processes and sends them to Google website for mapping. This will clean up leading and trailing junk, but assumes that the numbers are separated only by spaces with or without a comma.
- "Download Academia PDF" uses a modified version of Ryan Baumann's script to get PDFs directly from academia.edu pages. Drop the script into the appropriate Library/Scripts/Applications/ folder and use it when you want the file from the current page. Drops it into your Downloads folder. Get the modified ruby from my fork of it. Works with Safari, FireFox, Chromium, and Chrome. Create an issue, if you want it for another browser.
- "OCR the clipboard" processes the image on the clipboard with tesseract to read the text on it and save that text to the clipboard. Will give an error if there isn't an image with text on the clipboard.
