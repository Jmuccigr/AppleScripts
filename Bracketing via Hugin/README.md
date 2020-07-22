# Introduction

This is a script to use Hugin's included tools to *align* a series of images of differing exposure times or focus and then *enfuse* them to create an effective HDR or high-DOF image.

## Version history
- 2014-08-24 0.1  Implements basic functionality with minimal error checking.
- 2014-08-24 0.11 Changed to usual Hugin location from RC4 version. Added intro comments.
- 2014-08-28 0.12 Added run handler and check for presence of Hugin.app in the Applications folder.
- 2014-09-04 0.13 Removed left-over de-bugging code and re-named to more accurately reflect the capabilities.
- 2014-09-17 0.14 Added ability to add parameters to enfuse.
- 2014-09-18 0.14 Forgot to increment version #. Improved error trapping and added long timeouts for commands.
- 2014-09-18 0.16 Added kludgey way to handle use of --save-masks, which was barfing without specification of folder in which to save masks. Moved dialogs to alerts where appropriate.
- 2014-09-20 0.17 Added more specific command to trash align-image-stack's files. Tweaked name of soft-mask files that gets saved.
- 2014-11-17 0.18 Fixed problem with error messages and some small typos.
- 2015-12-13 0.19 Bring app to front upon run.
