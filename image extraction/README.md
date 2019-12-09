---
title: Image Extraction
author: John D. Muccigrosso
date: Sunday, 29 September 2019
---

These AppleScripts and associated droplet apps (do we still call them that?) will extract images from common file types.

## Get PDF images

This script relies on the [poppler](https://poppler.freedesktop.org) set of utilities to do its work. pdfinfo reads the number of pages, just for error-checking purposes, and pdfimages does the dirty work. Drop a PDF on it and the script will make sure it has images and then extract all the images in their original format (except for jb2e which becomes png) from the page range you ask it to, and save the images with your chosen name in the original folder.

I've embedded the two binaries in the app bundle and it seems to work. Let me know if it doesn't.

Be warned: some PDFs have images put in them in strange ways, so what comes up sometimes needs some massaging. A simple `magick -append` will often do the trick, but sometimes it takes more. I've made a droplet that handles that for you, too, over in another repository.

## Get All PDF images

As the name suggests, this just pulls **all** the images from a PDF and dumps them into a directory. For when the PDF is small enough or you just don't want to take the time to figure out which pages you want. Conveniently pdfimages gives the images page-based names.

## Get Office images

This script is a little simpler since it just unzips the word or pptx /media folder inside the docx/pptx bundle and deposits those files inside the original folder, creating what is hopefully a uniquely named sub-folder. (The name is based on the date and time and filename, so it **should** be unique.) Right now the unzips everything, but I should probably have it just do the image files, though it doesn't look like unzip's support of regex is so great. Since `unzip` is built into MacOS, this doesn't require any monkey business.

I've also included zipped versions of the app versions.
