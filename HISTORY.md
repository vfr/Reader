
## History

2016-01-20: Version 2.8.7

	- Added iOS 9 and iPad Pro support.
	- iPhone 6 Plus and iPhone 6S Plus @3x graphics.
	- Sticky paging on iPod/iPhone workaround fix.

2015-03-24: Version 2.8.6

	- Added French and Spanish Localizable.strings
	- iOS 8 UIScrollView bug revisited - again...

2014-12-07: Version 2.8.5

	- iPhone 6 and 6 Plus support - launch images and thumbnails.
	- iOS 8 UIScrollView bug revisited - possibly fixed in 8.1.1?

2014-10-18: Version 2.8.4

	- Fixed a rather daft design decision in ReaderDocument.

2014-09-20: Version 2.8.3

	- Workaround for bug in 32-bit iOS UIScrollView when UIUserInterfaceIdiomPhone.

2014-09-17: Version 2.8.2

	- Tweaked the flat toolbar look.

2014-09-16: Version 2.8.1

	- Replaced READER_ENABLE_MAIL with a canEmail document property.
	- Replaced READER_ENABLE_EXPORT with a canExport document property.
	- Replaced READER_ENABLE_PRINT with a canPrint document property.
	- Compile time READER_FLAT_UI option now flattens the toolbars.

2014-09-14: Version 2.8.0

	- Double-tap to zoom now centers the zoom on the location of the double-tap.
	- The toolbar Done button now adjusts its width based on the width of its localized text.
	- Reworked handling of views in the ReaderViewController paging UIScrollView. You can now page as fast as the device can go.
	- Added a READER_ENABLE_EXPORT compile time option. Uses UIDocumentInteractionController to export the current PDF to other applications.
	- Added a READER_FLAT_UI compile time option that (for now only) disables button borders.
	- Fixed crash under iOS 8 - please see the note in the ReaderDocument class file.
	- Cleaned up 64-bit compiler warnings for various format strings.

2013-11-19: Version 2.7.3

	- Retina and zoom levels bug fixes.
	- PDF annotation URI handling bug fix.

2013-10-24: Version 2.7.2

	- iOS 7 status bar handling bug fixes.

2013-10-12: Version 2.7.1

	- Changed 'unsafe_unretained' to 'weak'.

2013-10-03: Version 2.7.0

	- iOS 7 and Xcode 5.0 support.

2013-06-04: Version 2.6.2

	- Touch two UIButton, exclusiveTouch = NO. Not good. Fixed.

2012-10-05: Version 2.6.1

	- Greatly improved thumb operation cancel handling.
	- iOS 4 support and various other miscellaneous fixes.

2012-09-24: Version 2.6.0

	- Refactored to use ARC memory management.
	- General code cleanup and modernization.
	- Added ReaderDocumentOutline class.

2012-04-16: Version 2.5.6

	- Now loads and decodes thumbnails on a background thread.
	- Added READER_DISABLE_RETINA #define performance option.

2012-04-10: Version 2.5.5

	- Handles PDF web links without http:// as the prefix.
	- Bug fix to PDF link handling with crop-boxed PDF files.
	- Some performance improvements on iPad 3rd generation.

2012-01-14: Version 2.5.4

	- Bug fix to PDF link handling in older format PDFs.
	- Changed from CC BY 3.0 License to MIT License.

2011-11-08: Version 2.5.3

	- Various refinements and minor bug fixes.

2011-10-15: Version 2.5.2

	- One (crashing) bug fix and one minor UI tweak.

2011-10-06: Version 2.5.1

	- Fixed content view centering under iOS 5.

2011-10-05: Version 2.5.0

	- Critical bug fixes and various assorted tweaks.

2011-09-20: Version 2.4.0

	- Replaced UIToolbars with custom UIView-based toolbars.

2011-09-14: Version 2.3.0

	- Added page thumbnail document navigation.
	- Added support for page bookmarks.

2011-09-10: Version 2.2.1

	- Added password handling to ReaderDocument plist unarchive.

2011-09-09: Version 2.2.0

	- A medium resolution page preview image is now shown first.
	- The page bar now uses small page thumbs instead of a slider.

2011-08-27: Version 2.1.1

	- Fixed rotation handling when in a UITabBarController.

2011-08-25: Version 2.1.0

	- Added PDF link (URI and document page) support.
	- Assorted code cleanup, optimizations and bug fixes.

2011-07-29: Version 2.0.0

	- Released v2.0 into the wild for general use.
