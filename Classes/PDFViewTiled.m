//
//	PDFViewTiled.m
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-01.
//	Copyright © 2010 Julius Oklamcak. All rights reserved.
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

@synthesize page;
@synthesize pages;

#pragma mark PDFViewTiled Class methods

+ (Class)layerClass
{
	return [PDFTiledLayer class];
}

#pragma mark PDFViewTiled Instance methods

/*
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		// ...UIView initialization code...
	}

	return self;
}
*/

- (id)initWithURL:(NSURL *)fileURL onPage:(NSInteger)onPage password:(NSString *)password frame:(CGRect)frame
{
	if (self = [self initWithFrame:frame])
	{
		if (fileURL != nil) // Check for non-nil file URL
		{
			_fileURL = [fileURL copy]; // Keep a copy of the file URL

			_password = [password copy]; // Keep a copy of the password

			_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);

			if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocRef
			{
				if (onPage < 1) onPage = 1; // Check the lower page bounds

				NSInteger count = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

				if (onPage > count) onPage = count; // Check the upper page bounds

				_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, onPage);

				if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
				{
					CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

					page = onPage; // Set the current page number
					pages = count; // Set the total page count
				}
				else // Error out with a diagnostic
				{
					CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

					NSAssert(NO, @"CGPDFPageRef == NULL");
				}
			}
			else // Error out with a diagnostic
			{
				NSAssert(NO, @"CGPDFDocRef == NULL");
			}
		}
		else // Error out with a diagnostic
		{
			NSAssert(NO, @"fileURL == nil");
		}
	}

	return self;
}

- (BOOL)changeFileURL:(NSURL *)fileURL onPage:(NSInteger)onPage password:(NSString *)password
{
	BOOL status = NO;

	if (fileURL != nil) // Check for non-nil file URL
	{
		CGPDFPageRef newPDFPageRef = NULL;
		CGPDFDocumentRef newPDFDocRef = NULL;

		newPDFDocRef = CGPDFDocumentCreateX((CFURLRef)fileURL, password);

		if (newPDFDocRef != NULL) // Check for non-NULL CGPDFDocRef
		{
			if (onPage < 1) onPage = 1; // Check the lower page bounds

			NSInteger count = CGPDFDocumentGetNumberOfPages(newPDFDocRef);

			if (onPage > count) onPage = count; // Check the upper page bounds

			newPDFPageRef = CGPDFDocumentGetPage(newPDFDocRef, onPage);

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

				[_fileURL release]; _fileURL = [fileURL copy]; // Keep a copy
				[_password release]; _password = [password copy]; // Ditto

				page = onPage; // Set the current page number
				pages = count; // Set the total page count

				status = YES; // Happy happy joy joy
			}
			else // Error out with a diagnostic
			{
				CGPDFDocumentRelease(newPDFDocRef), newPDFDocRef = NULL;

				NSAssert(NO, @"CGPDFPageRef == NULL");
			}
		}
		else // Error out with a diagnostic
		{
			NSAssert(NO, @"CGPDFDocRef == NULL");
		}
	}
	else // Error out with a diagnostic
	{
		NSAssert(NO, @"fileURL == nil");
	}

	return status;
}

- (void)gotoPage:(NSInteger)newPage
{
	if (_PDFDocRef != NULL)
	{
		if (newPage < 1) // Check lower page bounds
			newPage = 1;
		else
			if (newPage > pages) // Check upper page bounds
				newPage = pages;

		if (newPage != page) // Only if page numbers differ
		{
			page = 0; // Clear the current page number

			@synchronized(self) // Block CATiledLayer thread
			{
				CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

				CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

				_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);

				if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocRef
				{
					_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, newPage);

					if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
					{
						CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

//						self.layer.contents = nil; // Clear CATiledLayer tile cache

						[self.layer setNeedsDisplay]; // Flag the layer for redraw

						page = newPage; // Set the current page number
					}
					else // Error out with a diagnostic
					{
						CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

						NSAssert(NO, @"CGPDFPageRef == NULL");
					}
				}
				else // Error out with a diagnostic
				{
					NSAssert(NO, @"CGPDFDocRef == NULL");
				}
			}
		}
	}
}

- (void)decrementPage
{
	if (_PDFDocRef != NULL)
	{
		[self gotoPage:(page - 1)];
	}
}

- (void)incrementPage
{
	if (_PDFDocRef != NULL)
	{
		[self gotoPage:(page + 1)];
	}
}

- (void)willRotate
{
	self.layer.hidden = YES;

	self.layer.contents = nil;
}

- (void)didRotate
{
	[self.layer setNeedsDisplay];

	self.layer.hidden = NO;
}

- (void)dealloc
{
	[_password release];

	CGPDFPageRelease(_PDFPageRef);

	CGPDFDocumentRelease(_PDFDocRef);

	[_fileURL release];

	[super dealloc];
}

#pragma mark CATiledLayer Delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	CGPDFPageRef drawPDFPageRef = NULL;
	CGPDFDocumentRef drawPDFDocRef = NULL;

	@synchronized(self) // Briefly block main thread
	{
		drawPDFDocRef = CGPDFDocumentRetain(_PDFDocRef);
		drawPDFPageRef = CGPDFPageRetain(_PDFPageRef);
	}

	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);

	CGContextFillRect(context, CGContextGetClipBoundingBox(context));

	if (drawPDFPageRef != NULL) // Render the page into the context
	{
		CGFloat boundsWidth = self.bounds.size.width;
		CGFloat boundsHeight = self.bounds.size.height;

		CGRect cropBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFCropBox);
		CGRect mediaBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFMediaBox);
		CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

//		NSInteger rotate = CGPDFPageGetRotationAngle(drawPDFPageRef);

		CGFloat effectiveWidth = effectiveRect.size.width;
		CGFloat effectiveHeight = effectiveRect.size.height;

		CGFloat widthScale = (boundsWidth / effectiveWidth);
		CGFloat heightScale = (boundsHeight / effectiveHeight);

		CGFloat scale = (widthScale < heightScale) ? widthScale : heightScale;

		CGFloat x_offset = ((boundsWidth - (effectiveWidth * scale)) / 2.0f);
		CGFloat y_offset = ((boundsHeight - (effectiveHeight * scale)) / 2.0f);

		y_offset = (boundsHeight - y_offset); // Co-ordinate system adjust

		CGFloat x_translate = floorf(x_offset - effectiveRect.origin.x);
		CGFloat y_translate = floorf(y_offset + effectiveRect.origin.y);

		CGContextTranslateCTM(context, x_translate, y_translate);

		CGContextScaleCTM(context, scale, -scale); // Mirror Y

		CGContextDrawPDFPage(context, drawPDFPageRef);
	}

	CGPDFPageRelease(drawPDFPageRef); // Cleanup
	CGPDFDocumentRelease(drawPDFDocRef);
}

@end
