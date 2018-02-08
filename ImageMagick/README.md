# ImageMagick scripts

This is a set of AppleScripts that simply take a file (or files) via drag-and-drop and process it with ImageMagick. As long as the `convert` command is on your system, they should work.

There are six sets of them:

1. Four scripts that chop a small amount off one of the sides of the image (3 or 4%) and then trim it. These are good when you've got, say, a black stripe along one side.
1. Four scripts that blank out a square in one of the corners and then trim it.
1. One script that blanks out squares in all four corners and then trims it.
1. One script that just trims the image with no pre-processing.
1. Four scripts that chop off a little on one side and then EITHER add the same amount (in white) to the opposite side, in effect shifting the image in the first direction, OR add the same amount *back* to that side, in effect erasing a strip from the image. (There are better ways to do this with ImageMagick, but this method makes the script simpler.)
1. One script that just deskews the image.

In each case, the original file is moved to the Trash and the new file is saved in its former place with the same name and then displayed via QuickLook. This means that if the process is overly aggressive and removes too much of the image, you can easily go get the original from the Trash and put it back, overwriting the new file.

Each script also has a second mode, activated by holding down the option key. In the case of the trim-only and shifting scripts, this mode makes them more aggressive in matching pixels to be trimmed or in the size of the shift, respectively. In the case of the other scripts, it causes them to remove or overwrite *fewer* pixels. In every case, the script also sounds your system *beep*, so you know that it's been activated (and you can let go of the key).

The shift scripts turn into erase scripts when the command key is held down. You can hold down both option and command to get a bigger strip erased.

## Zip file

I've also included a zip file of a folder containing the scripts as applications. I think it should look the same on your computer as on mine, as long as the view is set to show the icons. I've got them arranged geometrically to match the part of the image that each works on.

![Contents of zip file](http://jmuccigr.github.io/images/trim_apps_2.png)

Naturally let me know if something's not working.
