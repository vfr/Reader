//
//	ReaderDocument.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
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

@interface ReaderDocument ()

@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong, readwrite) NSString *filePath;

@end

@implementation ReaderDocument
{
	NSString *_guid;

	NSDate *_fileDate;

	NSDate *_lastOpen;

	NSNumber *_fileSize;

	NSNumber *_pageCount;

	NSNumber *_pageNumber;

	NSMutableIndexSet *_bookmarks;

	NSString *_password;

	NSString *_fileName;

	NSString *_filePath;

	NSURL *_fileURL;
}

#pragma mark - Properties

@synthesize guid = _guid;
@synthesize fileDate = _fileDate;
@synthesize lastOpen = _lastOpen;
@synthesize fileSize = _fileSize;
@synthesize pageCount = _pageCount;
@synthesize pageNumber = _pageNumber;
@synthesize bookmarks = _bookmarks;
@synthesize password = _password;
@synthesize filePath = _filePath;
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
	NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton

	NSURL *pathURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

	return [pathURL path]; // Path to the application's "~/Documents" directory
}

+ (NSString *)applicationSupportPath
{
	NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton

	NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

	return [pathURL path]; // Path to the application's "~/Library/Application Support" directory
}

+ (NSString *)archiveFilePath:(NSString *)fileName
{
	NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton

	NSString *applicationSupportPath = [ReaderDocument applicationSupportPath]; // See above

	NSString *archivePath = [applicationSupportPath stringByAppendingPathComponent:@"Reader Metadata"];

	[fileManager createDirectoryAtPath:archivePath withIntermediateDirectories:NO attributes:nil error:NULL];

	NSString *archiveName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];

	return [archivePath stringByAppendingPathComponent:archiveName]; // "{archivePath}/'fileName'.plist"
}

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filePath password:(NSString *)phrase
{
	ReaderDocument *document = nil; // ReaderDocument object

	NSString *fileName = [filePath lastPathComponent]; // File name only

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:fileName];

	@try // Unarchive an archived ReaderDocument object from its property list
	{
		document = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];

		if (document != nil) // Set the document's file path and password properties
		{
			document.filePath = [filePath copy]; document.password = [phrase copy];
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

	if (document == nil) // Unarchive failed so create a new ReaderDocument object
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

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)phrase
{
	if ((self = [super init])) // Initialize superclass first
	{
		if ([ReaderDocument isPDF:filePath] == YES) // Valid PDF
		{
			_guid = [ReaderDocument GUID]; // Create document's GUID

			_password = [phrase copy]; // Keep copy of document password

			_filePath = [filePath copy]; // Keep copy of document file path

			_pageNumber = [NSNumber numberWithInteger:1]; // Start on page one

			_bookmarks = [NSMutableIndexSet new]; // Bookmarked pages index set

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

			NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton

			NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_filePath error:NULL];

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
	if (_fileName == nil) _fileName = [_filePath lastPathComponent];

	return _fileName;
}

- (NSURL *)fileURL
{
	if (_fileURL == nil) _fileURL = [[NSURL alloc] initFileURLWithPath:_filePath isDirectory:NO];

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
	CFURLRef docURLRef = (__bridge CFURLRef)[self fileURL]; // CFURLRef from NSURL

	CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateUsingUrl(docURLRef, _password);

	if (thePDFDocRef != NULL) // Get the total number of pages in the document
	{
		NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);

		_pageCount = [NSNumber numberWithInteger:pageCount];

		CGPDFDocumentRelease(thePDFDocRef); // Cleanup
	}

	NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton

	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_filePath error:NULL];

	_fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date

	_fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)
}

#pragma mark - NSCoding protocol methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_guid forKey:@"FileGUID"];

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
