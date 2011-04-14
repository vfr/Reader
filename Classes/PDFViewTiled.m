//
//	PDFViewTiled.m
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

#import "PDFViewTiled.h"
#import "PDFTiledLayer.h"
#import "CGPDFDocument.h"

@implementation PDFViewTiled

#pragma mark Properties

@synthesize pageCount = _pageCount;
@synthesize currentPage = _currentPage;

#pragma mark PDFViewTiled class methods

+ (Class)layerClass
{
	return [PDFTiledLayer class];
}

#pragma mark PDFViewTiled instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeScaleAspectFit; // For proper view rotation handling
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // N.B.
		self.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password frame:(CGRect)frame
{
	if ((self = [self initWithFrame:frame]))
	{
		if (fileURL != nil) // Check for non-nil file URL
		{
			_fileURL = [fileURL copy]; // Keep a copy of the file URL

			_password = [password copy]; // Keep a copy of the password

			_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);

			if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
			{
				if (page < 1) page = 1; // Check the lower page bounds

				NSInteger count = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

				if (page > count) page = count; // Check the upper page bounds

				_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page);

				if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
				{
					CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

					_currentPage = page; // Set the current page number

					_pageCount = count; // Set the total page count
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
	}

	return self;
}

- (BOOL)changeFileURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password
{
	BOOL status = NO; // Default flag

	if (fileURL != nil) // Check for non-nil file URL
	{
		CGPDFPageRef newPDFPageRef = NULL;

		CGPDFDocumentRef newPDFDocRef = NULL;

		newPDFDocRef = CGPDFDocumentCreateX((CFURLRef)fileURL, password);

		if (newPDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (page < 1) page = 1; // Check the lower page bounds

			NSInteger count = CGPDFDocumentGetNumberOfPages(newPDFDocRef);

			if (page > count) page = count; // Check the upper page bounds

			newPDFPageRef = CGPDFDocumentGetPage(newPDFDocRef, page);

			if (newPDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
			{
				CGPDFPageRetain(newPDFPageRef); // Retain the PDF page

				@synchronized(self) // Block the CATiledLayer thread
				{
					CGPDFPageRelease(_PDFPageRef); _PDFPageRef = newPDFPageRef;

					CGPDFDocumentRelease(_PDFDocRef); _PDFDocRef = newPDFDocRef;

					self.layer.contents = nil; // Clear CATiledLayer tile cache

					[self.layer setNeedsDisplay]; // Flag the layer for redraw
				}

				[_password release]; _password = [password copy]; // Keep a copy

				[_fileURL release]; _fileURL = [fileURL copy]; // Keep a copy

				_currentPage = page; // Set the current page number

				_pageCount = count; // Set the total page count

				status = YES; // Happiness is success
			}
			else // Error out with a diagnostic
			{
				CGPDFDocumentRelease(newPDFDocRef), newPDFDocRef = NULL;

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

	return status;
}

- (void)gotoPage:(NSInteger)page
{
	if (_PDFDocRef != NULL)
	{
		if (page < 1) // Check lower page bounds
			page = 1;
		else
			if (page > _pageCount) // Check upper page bounds
				page = _pageCount;

		if (page != _currentPage) // Only if page numbers differ
		{
			_currentPage = 0; // Clear the current page number

			@synchronized(self) // Block CATiledLayer thread
			{
				CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

				CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

				_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);

				if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
				{
					_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page);

					if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
					{
						CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

						//self.layer.contents = nil; // Clear CATiledLayer tile cache

						[self.layer setNeedsDisplay]; // Flag the layer for redraw

						_currentPage = page; // Set the current page number
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
		}
	}
}

- (CGSize)currentPageSize
{
	CGSize pageSize = CGSizeZero; // Error default size

	if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
	{
		CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
		CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
		CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

		NSInteger degrees = CGPDFPageGetRotationAngle(_PDFPageRef);

		if (degrees == 0) // Check for page rotation
		{
			pageSize = effectiveRect.size;
		}
		else // Rotate the effective rect so many degrees
		{
			CGFloat radians = (degrees * M_PI / 180.0);

			CGAffineTransform rotation = CGAffineTransformMakeRotation(radians);

			CGRect rotatedRect = CGRectApplyAffineTransform(effectiveRect, rotation);

			pageSize = rotatedRect.size;
		}
	}

	return pageSize;
}

- (void)decrementPage
{
	if (_PDFDocRef != NULL)
	{
		[self gotoPage:(_currentPage - 1)];
	}
}

- (void)incrementPage
{
	if (_PDFDocRef != NULL)
	{
		[self gotoPage:(_currentPage + 1)];
	}
}

- (void)dealloc
{
	@synchronized(self) // Block any other threads
	{
		CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

		CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
	}

	[_fileURL release]; [_password release];

	[super dealloc];
}

#pragma mark CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	CGPDFPageRef drawPDFPageRef = NULL;

	CGPDFDocumentRef drawPDFDocRef = NULL;

	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain(_PDFDocRef);

		drawPDFPageRef = CGPDFPageRetain(_PDFPageRef);
	}

	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White

	CGContextFillRect(context, CGContextGetClipBoundingBox(context));

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

			CGFloat x_translate = (x_offset - effectiveRect.origin.x);
			CGFloat y_translate = (y_offset + effectiveRect.origin.y);

			CGContextTranslateCTM(context, x_translate, y_translate);

			CGContextScaleCTM(context, scale, -scale); // Mirror Y
		}
		else // Use CGPDFPageGetDrawingTransform for pages with rotation (AKA kludge)
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
