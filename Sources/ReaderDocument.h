//
//	ReaderDocument.h
//	Reader v2.0.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import <Foundation/Foundation.h>

@interface ReaderDocument : NSObject <NSCoding>
{
@private // Instance variables

	NSDate *_fileDate;

	NSDate *_lastOpen;

	NSNumber *_fileSize;

	NSNumber *_pageCount;

	NSNumber *_pageNumber;

	NSString *_fileName;

	NSString *_password;

	NSURL *_fileURL;
}

@property (nonatomic, retain, readonly) NSDate *fileDate;
@property (nonatomic, retain, readwrite) NSDate *lastOpen;
@property (nonatomic, retain, readonly) NSNumber *fileSize;
@property (nonatomic, retain, readonly) NSNumber *pageCount;
@property (nonatomic, retain, readwrite) NSNumber *pageNumber;
@property (nonatomic, retain, readonly) NSString *fileName;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, retain, readonly) NSURL *fileURL;

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename;

- (id)initWithFilePath:(NSString *)fullFilePath password:(NSString *)phrase;

- (void)saveReaderDocument;

@end
