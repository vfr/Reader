//
//	PDFViewTiled.h
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-01.
//	Copyright © 2010-2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import <UIKit/UIKit.h>

@interface PDFViewTiled : UIView
{
@private // Instance variables

	NSURL *_fileURL;
	NSString *_password;

	NSInteger _pageCount;
	NSInteger _currentPage;

	CGPDFDocumentRef _PDFDocRef;
	CGPDFPageRef _PDFPageRef;
}

@property (nonatomic, assign, readonly) NSInteger pageCount;
@property (nonatomic, assign, readonly) NSInteger currentPage;

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password frame:(CGRect)frame;

- (BOOL)changeFileURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password;

- (void)gotoPage:(NSInteger)page;

- (CGSize)currentPageSize;

- (void)decrementPage;
- (void)incrementPage;

@end
