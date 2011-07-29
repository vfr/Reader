//
//	ReaderContentPage.h
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

#import <UIKit/UIKit.h>

@interface ReaderContentPage : UIView
{
@private // Instance variables

	NSURL *_fileURL;

	NSString *_password;

	CGPDFDocumentRef _PDFDocRef;

	CGPDFPageRef _PDFPageRef;

	CGSize _pageSize;
}

@property (nonatomic, assign, readonly) CGSize pageSize;

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase;

@end
