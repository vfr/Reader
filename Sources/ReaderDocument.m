//
//	ReaderDocument.m
//	Reader v2.8.1
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2014 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderDocument.h"
#import "CGPDFDocument.h"
#import <fcntl.h>

//
//	Note: The code in this class assumes that PDF files live somewhere off of an
//	application's ~/Documents directory. Since whenever an app is updated, its file
//	path changes, we cannot store the full file path in the object archive, so we
//	must store a relative file path and build up a full file path with it. As well,
//	since as of iOS 8, the application's ~/Documents directory no longer lives in
//	its bundle, any bundled PDF files must be copied into the the application's
//	~/Documents directory before they can be accessed.
//

@implementation ReaderDocument
{
	NSString *_guid;

	NSDate *_fileDate;

	NSDate *_lastOpen;

	NSNumber *_fileSize;

	NSNumber *_pageCount;

	NSNumber *_pageNumber;

	NSMutableIndexSet *_bookmarks;

	NSString *_fileName;

	NSString *_password;

	NSURL *_fileURL;
}

#pragma mark - Properties

@synthesize guid = _guid;
@synthesize fileDate = _fileDate;
@synthesize fileSize = _fileSize;
@synthesize pageCount = _pageCount;
@synthesize pageNumber = _pageNumber;
@synthesize bookmarks = _bookmarks;
@synthesize lastOpen = _lastOpen;
@synthesize password = _password;
@dynamic fileName, fileURL;
@dynamic canEmail, canExport, canPrint;

#pragma mark - ReaderDocument class methods

+ (NSString *)GUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);

	CFStringRef theString = CFUUIDCreateString(NULL, theUUID);

	NSString *unique = [NSString stringWithString:(__bridge id)theString];

	CFRelease(theString); CFRelease(theUUID); // Cleanup CF objects

	return unique;
}

+ (NSString *)documentsPath
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSURL *pathURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

	return [pathURL path]; // Path to the application's "~/Documents" directory
}

+ (NSString *)applicationSupportPath
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

	return [pathURL path]; // Path to the application's "~/Library/Application Support" directory
}

+ (NSString *)relativeFilePath:(NSString *)fullFilePath
{
	assert(fullFilePath != nil); // Ensure that the full file path is not nil

	NSString *documentsPath = [ReaderDocument documentsPath]; // Get the documents path

	NSRange range = [fullFilePath rangeOfString:documentsPath]; // Look for the documents path

	assert(range.location != NSNotFound); // Ensure that the documents path is in the full file path

	return [fullFilePath stringByReplacingCharactersInRange:range withString:@""]; // Strip it out
}

+ (NSString *)archiveFilePath:(NSString *)filename
{
	assert(filename != nil); // Ensure that the archive file name is not nil

	//NSString *archivePath = [ReaderDocument documentsPath]; // Application's "~/Documents" path

	NSString *archivePath = [ReaderDocument applicationSupportPath]; // Application's "~/Library/Application Support" path

	NSString *archiveName = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];

	return [archivePath stringByAppendingPathComponent:archiveName]; // "{archivePath}/'filename'.plist"
}

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename password:(NSString *)phrase
{
	ReaderDocument *document = nil; // ReaderDocument object

	NSString *withName = [filename lastPathComponent]; // File name only

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:withName];

	@try // Unarchive an archived ReaderDocument object from its property list
	{
		document = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];

		if ((document != nil) && (phrase != nil)) // Set the document password
		{
			[document setValue:[phrase copy] forKey:@"password"];
		}
	}
	@catch (NSException *exception) // Exception handling (just in case O_o)
	{
		#ifdef DEBUG
			NSLog(@"%s Caught %@: %@", __FUNCTION__, [exception name], [exception reason]);
		#endif
	}

	return document;
}

+ (ReaderDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase
{
	ReaderDocument *document = nil; // ReaderDocument object

	document = [ReaderDocument unarchiveFromFileName:filePath password:phrase];

	if (document == nil) // Unarchive failed so we create a new ReaderDocument object
	{
		document = [[ReaderDocument alloc] initWithFilePath:filePath password:phrase];
	}

	return document;
}

+ (BOOL)isPDF:(NSString *)filePath
{
	BOOL state = NO;

	if (filePath != nil) // Must have a file path
	{
		const char *path = [filePath fileSystemRepresentation];

		int fd = open(path, O_RDONLY); // Open the file

		if (fd > 0) // We have a valid file descriptor
		{
			const char sig[1024]; // File signature buffer

			ssize_t len = read(fd, (void *)&sig, sizeof(sig));

			state = (strnstr(sig, "%PDF", len) != NULL);

			close(fd); // Close the file
		}
	}

	return state;
}

#pragma mark - ReaderDocument instance methods

- (instancetype)initWithFilePath:(NSString *)fullFilePath password:(NSString *)phrase
{
	if ((self = [super init])) // Initialize superclass first
	{
		if ([ReaderDocument isPDF:fullFilePath] == YES) // Valid PDF
		{
			_guid = [ReaderDocument GUID]; // Create the document's GUID

			_password = [phrase copy]; // Keep copy of any document password

			_bookmarks = [NSMutableIndexSet new]; // Bookmarked pages index set

			_pageNumber = [NSNumber numberWithInteger:1]; // Start on page one

			_fileName = [ReaderDocument relativeFilePath:fullFilePath]; // File name

			CFURLRef docURLRef = (__bridge CFURLRef)[self fileURL]; // CFURLRef from NSURL

			CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateUsingUrl(docURLRef, _password);

			if (thePDFDocRef != NULL) // Get the total number of pages in the document
			{
				NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);

				_pageCount = [NSNumber numberWithInteger:pageCount];

				CGPDFDocumentRelease(thePDFDocRef); // Cleanup
			}
			else // Cupertino, we have a problem with the document
			{
				NSAssert(NO, @"CGPDFDocumentRef == NULL");
			}

			_lastOpen = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];

			NSFileManager *fileManager = [NSFileManager new]; // File manager instance

			NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];

			_fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date

			_fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)

			[self archiveDocumentProperties]; // Archive ReaderDocument object
		}
		else // Not a valid PDF file
		{
			self = nil;
		}
	}

	return self;
}

- (NSString *)fileName
{
	return [_fileName lastPathComponent];
}

- (NSURL *)fileURL
{
	if (_fileURL == nil) // Create and keep the file URL the first time it is requested
	{
		NSString *fullFilePath = [[ReaderDocument documentsPath] stringByAppendingPathComponent:_fileName];

		_fileURL = [[NSURL alloc] initFileURLWithPath:fullFilePath isDirectory:NO]; // File URL from full file path
	}

	return _fileURL;
}

- (BOOL)canEmail
{
	return YES;
}

- (BOOL)canExport
{
	return YES;
}

- (BOOL)canPrint
{
	return YES;
}

- (BOOL)archiveDocumentProperties
{
	NSString *archiveFilePath = [ReaderDocument archiveFilePath:[self fileName]];

	return [NSKeyedArchiver archiveRootObject:self toFile:archiveFilePath];
}

- (void)updateDocumentProperties
{
	CFURLRef docURLRef = (__bridge CFURLRef)self.fileURL; // File URL

	CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(docURLRef);

	if (thePDFDocRef != NULL) // Get the number of pages in the document
	{
		NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);

		_pageCount = [NSNumber numberWithInteger:pageCount];

		CGPDFDocumentRelease(thePDFDocRef); // Cleanup
	}

	NSString *fullFilePath = [self.fileURL path]; // Full file path

	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];

	_fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date

	_fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)
}

#pragma mark - NSCoding protocol methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_guid forKey:@"FileGUID"];

	[encoder encodeObject:_fileName forKey:@"FileName"];

	[encoder encodeObject:_fileDate forKey:@"FileDate"];

	[encoder encodeObject:_pageCount forKey:@"PageCount"];

	[encoder encodeObject:_pageNumber forKey:@"PageNumber"];

	[encoder encodeObject:_bookmarks forKey:@"Bookmarks"];

	[encoder encodeObject:_fileSize forKey:@"FileSize"];

	[encoder encodeObject:_lastOpen forKey:@"LastOpen"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init])) // Superclass init
	{
		_guid = [decoder decodeObjectForKey:@"FileGUID"];

		_fileName = [decoder decodeObjectForKey:@"FileName"];

		_fileDate = [decoder decodeObjectForKey:@"FileDate"];

		_pageCount = [decoder decodeObjectForKey:@"PageCount"];

		_pageNumber = [decoder decodeObjectForKey:@"PageNumber"];

		_bookmarks = [decoder decodeObjectForKey:@"Bookmarks"];

		_fileSize = [decoder decodeObjectForKey:@"FileSize"];

		_lastOpen = [decoder decodeObjectForKey:@"LastOpen"];

		if (_guid == nil) _guid = [ReaderDocument GUID];

		if (_bookmarks != nil)
			_bookmarks = [_bookmarks mutableCopy];
		else
			_bookmarks = [NSMutableIndexSet new];
	}

	return self;
}

@end
