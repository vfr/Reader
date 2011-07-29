//
//	ReaderContentPage.m
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

#import "ReaderContentPage.h"
#import "ReaderContentTile.h"
#import "CGPDFDocument.h"

@implementation ReaderContentPage

#pragma mark Properties

@synthesize pageSize = _pageSize;

#pragma mark ReaderContentPage class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [ReaderContentTile class];
}

#pragma mark ReaderContentPage instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	UIView *view = nil;

	if (CGRectIsEmpty(frame) == false)
	{
		if ((self = [super initWithFrame:frame]))
		{
			self.autoresizesSubviews = NO;
			self.userInteractionEnabled = NO;
			self.clearsContextBeforeDrawing = NO;
			self.contentMode = UIViewContentModeRedraw;
			self.autoresizingMask = UIViewAutoresizingNone;
			self.backgroundColor = [UIColor clearColor];

			view = self; // Return self
		}
	}
	else // Handle invalid frame size
	{
		[self release];
	}

	return view;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGRect viewRect = CGRectZero; // View rect

	if (fileURL != nil) // Check for non-nil file URL
	{
		_fileURL = [fileURL copy]; // Keep a copy of the file URL

		_password = [phrase copy]; // Keep a copy of any given password

		_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);

		if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (page < 1) page = 1; // Check the lower page bounds

			NSInteger pages = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

			if (page > pages) page = pages; // Check the upper page bounds

			_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Page

			if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
			{
				CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

				CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
				CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
				CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

				NSInteger degrees = CGPDFPageGetRotationAngle(_PDFPageRef); // Angle

				NSInteger page_w; NSInteger page_h; // Page size (adjusted)

				if (degrees == 0) // Check for any page rotation
				{
					page_w = effectiveRect.size.width; page_h = effectiveRect.size.height;
				}
				else // Rotate the effective rect so many degrees
				{
					CGFloat radians = (degrees * M_PI / 180.0);

					CGAffineTransform rotation = CGAffineTransformMakeRotation(radians);

					CGRect rotatedRect = CGRectApplyAffineTransform(effectiveRect, rotation);

					page_w = rotatedRect.size.width; page_h = rotatedRect.size.height;
				}

				if (page_w % 2) page_w--; if (page_h %2) page_h--; // Even out page size

				_pageSize = CGSizeMake(page_w, page_h); viewRect.size = _pageSize;
			}
			else // Error out with a diagnostic
			{
				CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

				NSAssert(NO, @"CGPDFPageRef == NULL");
			}
		}
		else // Error out with a diagnostic
		{
			NSAssert(NO, @"CGPDFDocumentRef == NULL");
		}
	}
	else // Error out with a diagnostic
	{
		NSAssert(NO, @"fileURL == nil");
	}

	return [self initWithFrame:viewRect];
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	@synchronized(self) // Block any other threads
	{
		CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

		CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
	}

	[_password release], _password = nil;

	[_fileURL release], _fileURL = nil;

	[super dealloc];
}

/*
- (void)layoutSubviews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
}
*/

#pragma mark CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPDFPageRef drawPDFPageRef = NULL;

	CGPDFDocumentRef drawPDFDocRef = NULL;

	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain(_PDFDocRef);

		drawPDFPageRef = CGPDFPageRetain(_PDFPageRef);
	}

	//CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White

	//CGContextFillRect(context, CGContextGetClipBoundingBox(context));

	if (drawPDFPageRef != NULL) // Render the page into the context
	{
		CGFloat boundsHeight = self.bounds.size.height;

		if (CGPDFPageGetRotationAngle(drawPDFPageRef) == 0)
		{
			CGFloat boundsWidth = self.bounds.size.width; // View width

			CGRect cropBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFCropBox);
			CGRect mediaBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFMediaBox);
			CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

			CGFloat effectiveWidth = effectiveRect.size.width;
			CGFloat effectiveHeight = effectiveRect.size.height;

			CGFloat widthScale = (boundsWidth / effectiveWidth);
			CGFloat heightScale = (boundsHeight / effectiveHeight);

			CGFloat scale = (widthScale < heightScale) ? widthScale : heightScale;

			CGFloat x_offset = ((boundsWidth - (effectiveWidth * scale)) / 2.0f);
			CGFloat y_offset = ((boundsHeight - (effectiveHeight * scale)) / 2.0f);

			y_offset = (boundsHeight - y_offset); // Co-ordinate system adjust

			CGFloat x_translate = (x_offset - (effectiveRect.origin.x * scale));
			CGFloat y_translate = (y_offset + (effectiveRect.origin.y * scale));

			CGContextTranslateCTM(context, x_translate, y_translate);

			CGContextScaleCTM(context, scale, -scale); // Mirror Y
		}
		else // Use CGPDFPageGetDrawingTransform for pages with rotation (AKA minor kludge)
		{
			CGContextTranslateCTM(context, 0.0f, boundsHeight); CGContextScaleCTM(context, 1.0f, -1.0f);

			CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, self.bounds, 0, true));
		}

		CGContextDrawPDFPage(context, drawPDFPageRef);
	}

	CGPDFPageRelease(drawPDFPageRef); // Cleanup

	CGPDFDocumentRelease(drawPDFDocRef);
}

@end
