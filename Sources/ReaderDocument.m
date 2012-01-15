//
//	ReaderDocument.m
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
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

@implementation ReaderDocument

#pragma mark Properties

@synthesize guid = _guid;
@synthesize fileDate = _fileDate;
@synthesize fileSize = _fileSize;
@synthesize pageCount = _pageCount;
@synthesize pageNumber = _pageNumber;
@synthesize bookmarks = _bookmarks;
@synthesize lastOpen = _lastOpen;
@synthesize password = _password;
@dynamic fileName, fileURL;

#pragma mark ReaderDocument class methods

+ (NSString *)GUID
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CFUUIDRef theUUID;
	CFStringRef theString;

	theUUID = CFUUIDCreate(NULL);

	theString = CFUUIDCreateString(NULL, theUUID);

	NSString *unique = [NSString stringWithString:(id)theString];

	CFRelease(theString); CFRelease(theUUID); // Cleanup

	return unique;
}

+ (NSString *)documentsPath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	return [documentsPaths objectAtIndex:0]; // Path to the application's "~/Documents" directory
}

+ (NSString *)applicationPath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	return [[documentsPaths objectAtIndex:0] stringByDeletingLastPathComponent]; // Strip "Documents" component
}

+ (NSString *)applicationSupportPath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSFileManager *fileManager = [[NSFileManager new] autorelease]; // File manager instance

	NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

	return [pathURL path]; // Path to the application's "~/Library/Application Support" directory
}

+ (NSString *)relativeFilePath:(NSString *)fullFilePath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(fullFilePath != nil); // Ensure that the full file path is not nil

	NSString *applicationPath = [ReaderDocument applicationPath]; // Get the application path

	NSRange range = [fullFilePath rangeOfString:applicationPath]; // Look for the application path

	assert(range.location != NSNotFound); // Ensure that the application path is in the full file path

	return [fullFilePath stringByReplacingCharactersInRange:range withString:@""]; // Strip it out
}

+ (NSString *)archiveFilePath:(NSString *)filename
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(filename != nil); // Ensure that the archive file name is not nil

	//NSString *archivePath = [ReaderDocument documentsPath]; // Application's "~/Documents" path

	NSString *archivePath = [ReaderDocument applicationSupportPath]; // Application's "~/Library/Application Support" path

	NSString *archiveName = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];

	return [archivePath stringByAppendingPathComponent:archiveName]; // "{archivePath}/'filename'.plist"
}

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename password:(NSString *)phrase
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	ReaderDocument *document = nil; // ReaderDocument object

	NSString *withName = [filename lastPathComponent]; // File name only

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:withName];

	@try // Unarchive an archived ReaderDocument object from its property list
	{
		document = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];

		if ((document != nil) && (phrase != nil)) // Set the document password
		{
			[document setValue:[[phrase copy] autorelease] forKey:@"password"];
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

+ (ReaderDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase;
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	ReaderDocument *document = nil; // ReaderDocument object

	document = [ReaderDocument unarchiveFromFileName:filePath password:phrase];

	if (document == nil) // Unarchive failed so we create a new ReaderDocument object
	{
		document = [[[ReaderDocument alloc] initWithFilePath:filePath password:phrase] autorelease];
	}

	return document;
}

+ (BOOL)isPDF:(NSString *)filePath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	BOOL state = NO;

	if (filePath != nil) // Must have a file path
	{
		const char *path = [filePath fileSystemRepresentation];

		int fd = open(path, O_RDONLY); // Open the file

		if (fd > 0) // We have a valid file descriptor
		{
			const unsigned char sig[4]; // File signature

			ssize_t len = read(fd, (void *)&sig, sizeof(sig));

			if (len == 4)
				if (sig[0] == '%')
					if (sig[1] == 'P')
						if (sig[2] == 'D')
							if (sig[3] == 'F')
								state = YES;

			close(fd); // Close the file
		}
	}

	return state;
}

#pragma mark ReaderDocument instance methods

- (id)initWithFilePath:(NSString *)fullFilePath password:(NSString *)phrase
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id object = nil; // ReaderDocument object

	if ([ReaderDocument isPDF:fullFilePath] == YES) // File must exist
	{
		if ((self = [super init])) // Initialize the superclass object first
		{
			_guid = [[ReaderDocument GUID] retain]; // Create a document GUID

			_password = [phrase copy]; // Keep a copy of any document password

			_bookmarks = [NSMutableIndexSet new]; // Bookmarked pages index set

			_pageNumber = [[NSNumber numberWithInteger:1] retain]; // Start page 1

			_fileName = [[ReaderDocument relativeFilePath:fullFilePath] retain];

			CFURLRef docURLRef = (CFURLRef)[self fileURL]; // CFURLRef from NSURL

			CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateX(docURLRef, _password);

			if (thePDFDocRef != NULL) // Get the number of pages in a document
			{
				NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);

				_pageCount = [[NSNumber numberWithInteger:pageCount] retain];

				CGPDFDocumentRelease(thePDFDocRef); // Cleanup
			}
			else // Cupertino, we have a problem with the document
			{
				NSAssert(NO, @"CGPDFDocumentRef == NULL");
			}

			NSFileManager *fileManager = [NSFileManager new]; // File manager

			_lastOpen = [[NSDate dateWithTimeIntervalSinceReferenceDate:0.0] retain]; // Last opened

			NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];

			_fileDate = [[fileAttributes objectForKey:NSFileModificationDate] retain]; // File date

			_fileSize = [[fileAttributes objectForKey:NSFileSize] retain]; // File size (bytes)

			[fileManager release]; [self saveReaderDocument]; // Save ReaderDocument object

			object = self; // Return initialized ReaderDocument object
		}
	}

	return object;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[_guid release], _guid = nil;

	[_fileURL release], _fileURL = nil;

	[_password release], _password = nil;

	[_fileName release], _fileName = nil;

	[_pageCount release], _pageCount = nil;

	[_pageNumber release], _pageNumber = nil;

	[_bookmarks release], _bookmarks = nil;

	[_fileSize release], _fileSize = nil;

	[_fileDate release], _fileDate = nil;

	[_lastOpen release], _lastOpen = nil;

	[super dealloc];
}

- (NSString *)fileName
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [_fileName lastPathComponent];
}

- (NSURL *)fileURL
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (_fileURL == nil) // Create and keep the file URL the first time it is requested
	{
		NSString *fullFilePath = [[ReaderDocument applicationPath] stringByAppendingPathComponent:_fileName];

		_fileURL = [[NSURL alloc] initFileURLWithPath:fullFilePath isDirectory:NO]; // File URL from full file path
	}

	return _fileURL;
}

- (BOOL)archiveWithFileName:(NSString *)filename
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:filename];

	return [NSKeyedArchiver archiveRootObject:self toFile:archiveFilePath];
}

- (void)saveReaderDocument
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self archiveWithFileName:[self fileName]];
}

- (void)updateProperties
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
}

#pragma mark NSCoding protocol methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[encoder encodeObject:_guid forKey:@"FileGUID"];

	[encoder encodeObject:_fileName forKey:@"FileName"];

	[encoder encodeObject:_fileDate forKey:@"FileDate"];

	[encoder encodeObject:_pageCount forKey:@"PageCount"];

	[encoder encodeObject:_pageNumber forKey:@"PageNumber"];

	[encoder encodeObject:_bookmarks forKey:@"Bookmarks"];

	[encoder encodeObject:_fileSize forKey:@"FileSize"];

	[encoder encodeObject:_lastOpen forKey:@"LastOpen"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init])) // Superclass init
	{
		_guid = [[decoder decodeObjectForKey:@"FileGUID"] retain];

		_fileName = [[decoder decodeObjectForKey:@"FileName"] retain];

		_fileDate = [[decoder decodeObjectForKey:@"FileDate"] retain];

		_pageCount = [[decoder decodeObjectForKey:@"PageCount"] retain];

		_pageNumber = [[decoder decodeObjectForKey:@"PageNumber"] retain];

		_bookmarks = [[decoder decodeObjectForKey:@"Bookmarks"] mutableCopy];

		_fileSize = [[decoder decodeObjectForKey:@"FileSize"] retain];

		_lastOpen = [[decoder decodeObjectForKey:@"LastOpen"] retain];

		if (_bookmarks == nil) _bookmarks = [NSMutableIndexSet new];

		if (_guid == nil) _guid = [[ReaderDocument GUID] retain];
	}

	return self;
}

@end
