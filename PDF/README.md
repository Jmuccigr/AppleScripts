# PDF-related AppleScripts:

- **Download Academia PDF**: uses a modified version of Ryan Baumann's script to get PDFs directly from academia.edu pages. Drop the script into the appropriate Library/Scripts/Applications/ folder and use it when you want the file from the current page. Drops it into your Downloads folder. Get the modified ruby from my fork of it. Works with Safari, FireFox, Chromium, and Chrome. Create an issue, if you want it for another browser.
- **Filter PDF**: removes one or more PDF layers: text, raster or vector images. The first helps in cases of poor OCR <cough>JSTOR<cough>; the last for watermarks or other repeating vector images on each page. Assumes Ghostscript is installed. Available as zipped droplet.
- **PDF page numbers**: puts page numbers onto existing pages of a PDF. Basic put handy. Puts the number pretty low at the bottom to avoid existing material. Assumes the presence of pdftk, pdfinfo, and pdflatex. Available as zipped droplet.
- **Put images into PDF**: combine dropped image files into a PDF via img2pdf. Size is customizable. Available as zipped droplet.
- **Strip PDF metadata w/python**: use exiftool and pikePDF to remove top-level metadata from PDF, optionally preserving author and title tags. Available as zipped droplet.
- **Strip PDF metadata**: same as previous except using qpdf and linearizing the final file which may increase its size. Available as zipped droplet.
