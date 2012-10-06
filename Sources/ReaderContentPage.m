//
//	ReaderContentPage.m
//	Reader v2.6.1
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

#import "ReaderConstants.h"
#import "ReaderContentPage.h"
#import "ReaderContentTile.h"
#import "CGPDFDocument.h"

@implementation ReaderContentPage
{
	NSMutableArray *_links;

	CGPDFDocumentRef _PDFDocRef;

	CGPDFPageRef _PDFPageRef;

	NSInteger _pageAngle;

	CGFloat _pageWidth;
	CGFloat _pageHeight;

	CGFloat _pageOffsetX;
	CGFloat _pageOffsetY;
}

#pragma mark ReaderContentPage class methods

+ (Class)layerClass
{
	return [ReaderContentTile class];
}

#pragma mark ReaderContentPage PDF link methods

- (void)highlightPageLinks
{
	if (_links.count > 0) // Add highlight views over all links
	{
		UIColor *hilite = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.15f];

		for (ReaderDocumentLink *link in _links) // Enumerate the links array
		{
			UIView *highlight = [[UIView alloc] initWithFrame:link.rect];

			highlight.autoresizesSubviews = NO;
			highlight.userInteractionEnabled = NO;
			highlight.contentMode = UIViewContentModeRedraw;
			highlight.autoresizingMask = UIViewAutoresizingNone;
			highlight.backgroundColor = hilite; // Color

			[self addSubview:highlight];
		}
	}
}

- (ReaderDocumentLink *)linkFromAnnotation:(CGPDFDictionaryRef)annotationDictionary
{
	ReaderDocumentLink *documentLink = nil; // Document link object

	CGPDFArrayRef annotationRectArray = NULL; // Annotation co-ordinates array

	if (CGPDFDictionaryGetArray(annotationDictionary, "Rect", &annotationRectArray))
	{
		CGPDFReal ll_x = 0.0f; CGPDFReal ll_y = 0.0f; // PDFRect lower-left X and Y
		CGPDFReal ur_x = 0.0f; CGPDFReal ur_y = 0.0f; // PDFRect upper-right X and Y

		CGPDFArrayGetNumber(annotationRectArray, 0, &ll_x); // Lower-left X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 1, &ll_y); // Lower-left Y co-ordinate

		CGPDFArrayGetNumber(annotationRectArray, 2, &ur_x); // Upper-right X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 3, &ur_y); // Upper-right Y co-ordinate

		if (ll_x > ur_x) { CGPDFReal t = ll_x; ll_x = ur_x; ur_x = t; } // Normalize Xs
		if (ll_y > ur_y) { CGPDFReal t = ll_y; ll_y = ur_y; ur_y = t; } // Normalize Ys

		ll_x -= _pageOffsetX; ll_y -= _pageOffsetY; // Offset lower-left co-ordinate
		ur_x -= _pageOffsetX; ur_y -= _pageOffsetY; // Offset upper-right co-ordinate

		switch (_pageAngle) // Page rotation angle (in degrees)
		{
			case 90: // 90 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				break;
			}

			case 270: // 270 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				ll_x = ((0.0f - ll_x) + _pageWidth);
				ur_x = ((0.0f - ur_x) + _pageWidth);
				break;
			}

			case 0: // 0 degree page rotation
			{
				ll_y = ((0.0f - ll_y) + _pageHeight);
				ur_y = ((0.0f - ur_y) + _pageHeight);
				break;
			}
		}

		NSInteger vr_x = ll_x; NSInteger vr_w = (ur_x - ll_x); // Integer X and width
		NSInteger vr_y = ll_y; NSInteger vr_h = (ur_y - ll_y); // Integer Y and height

		CGRect viewRect = CGRectMake(vr_x, vr_y, vr_w, vr_h); // View CGRect from PDFRect

		documentLink = [ReaderDocumentLink newWithRect:viewRect dictionary:annotationDictionary];
	}

	return documentLink;
}

- (void)buildAnnotationLinksList
{
	_links = [NSMutableArray new]; // Links list array

	CGPDFArrayRef pageAnnotations = NULL; // Page annotations array

	CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(_PDFPageRef);

	if (CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations) == true)
	{
		NSInteger count = CGPDFArrayGetCount(pageAnnotations); // Number of annotations

		for (NSInteger index = 0; index < count; index++) // Iterate through all annotations
		{
			CGPDFDictionaryRef annotationDictionary = NULL; // PDF annotation dictionary

			if (CGPDFArrayGetDictionary(pageAnnotations, index, &annotationDictionary) == true)
			{
				const char *annotationSubtype = NULL; // PDF annotation subtype string

				if (CGPDFDictionaryGetName(annotationDictionary, "Subtype", &annotationSubtype) == true)
				{
					if (strcmp(annotationSubtype, "Link") == 0) // Found annotation subtype of 'Link'
					{
						ReaderDocumentLink *documentLink = [self linkFromAnnotation:annotationDictionary];

						if (documentLink != nil) [_links insertObject:documentLink atIndex:0]; // Add link
					}
				}
			}
		}

		//[self highlightPageLinks]; // Link support debugging
	}
}

- (CGPDFArrayRef)destinationWithName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node
{
	CGPDFArrayRef destinationArray = NULL;

	CGPDFArrayRef limitsArray = NULL; // Limits array

	if (CGPDFDictionaryGetArray(node, "Limits", &limitsArray) == true)
	{
		CGPDFStringRef lowerLimit = NULL; CGPDFStringRef upperLimit = NULL;

		if (CGPDFArrayGetString(limitsArray, 0, &lowerLimit) == true) // Lower limit
		{
			if (CGPDFArrayGetString(limitsArray, 1, &upperLimit) == true) // Upper limit
			{
				const char *ll = (const char *)CGPDFStringGetBytePtr(lowerLimit); // Lower string
				const char *ul = (const char *)CGPDFStringGetBytePtr(upperLimit); // Upper string

				if ((strcmp(destinationName, ll) < 0) || (strcmp(destinationName, ul) > 0))
				{
					return NULL; // Destination name is outside this node's limits
				}
			}
		}
	}

	CGPDFArrayRef namesArray = NULL; // Names array

	if (CGPDFDictionaryGetArray(node, "Names", &namesArray) == true)
	{
		NSInteger namesCount = CGPDFArrayGetCount(namesArray);

		for (NSInteger index = 0; index < namesCount; index += 2)
		{
			CGPDFStringRef destName; // Destination name string

			if (CGPDFArrayGetString(namesArray, index, &destName) == true)
			{
				const char *dn = (const char *)CGPDFStringGetBytePtr(destName);

				if (strcmp(dn, destinationName) == 0) // Found the destination name
				{
					if (CGPDFArrayGetArray(namesArray, (index + 1), &destinationArray) == false)
					{
						CGPDFDictionaryRef destinationDictionary = NULL; // Destination dictionary

						if (CGPDFArrayGetDictionary(namesArray, (index + 1), &destinationDictionary) == true)
						{
							CGPDFDictionaryGetArray(destinationDictionary, "D", &destinationArray);
						}
					}

					return destinationArray; // Return the destination array
				}
			}
		}
	}

	CGPDFArrayRef kidsArray = NULL; // Kids array

	if (CGPDFDictionaryGetArray(node, "Kids", &kidsArray) == true)
	{
		NSInteger kidsCount = CGPDFArrayGetCount(kidsArray);

		for (NSInteger index = 0; index < kidsCount; index++)
		{
			CGPDFDictionaryRef kidNode = NULL; // Kid node dictionary

			if (CGPDFArrayGetDictionary(kidsArray, index, &kidNode) == true) // Recurse into node
			{
				destinationArray = [self destinationWithName:destinationName inDestsTree:kidNode];

				if (destinationArray != NULL) return destinationArray; // Return destination array
			}
		}
	}

	return NULL;
}

- (id)annotationLinkTarget:(CGPDFDictionaryRef)annotationDictionary
{
	id linkTarget = nil; // Link target object

	CGPDFStringRef destName = NULL; const char *destString = NULL;

	CGPDFDictionaryRef actionDictionary = NULL; CGPDFArrayRef destArray = NULL;

	if (CGPDFDictionaryGetDictionary(annotationDictionary, "A", &actionDictionary) == true)
	{
		const char *actionType = NULL; // Annotation action type string

		if (CGPDFDictionaryGetName(actionDictionary, "S", &actionType) == true)
		{
			if (strcmp(actionType, "GoTo") == 0) // GoTo action type
			{
				if (CGPDFDictionaryGetArray(actionDictionary, "D", &destArray) == false)
				{
					CGPDFDictionaryGetString(actionDictionary, "D", &destName);
				}
			}
			else // Handle other link action type possibility
			{
				if (strcmp(actionType, "URI") == 0) // URI action type
				{
					CGPDFStringRef uriString = NULL; // Action's URI string

					if (CGPDFDictionaryGetString(actionDictionary, "URI", &uriString) == true)
					{
						const char *uri = (const char *)CGPDFStringGetBytePtr(uriString); // Destination URI string

						linkTarget = [NSURL URLWithString:[NSString stringWithCString:uri encoding:NSASCIIStringEncoding]];
					}
				}
			}
		}
	}
	else // Handle other link target possibilities
	{
		if (CGPDFDictionaryGetArray(annotationDictionary, "Dest", &destArray) == false)
		{
			if (CGPDFDictionaryGetString(annotationDictionary, "Dest", &destName) == false)
			{
				CGPDFDictionaryGetName(annotationDictionary, "Dest", &destString);
			}
		}
	}

	if (destName != NULL) // Handle a destination name
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(_PDFDocRef);

		CGPDFDictionaryRef namesDictionary = NULL; // Destination names in the document

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Names", &namesDictionary) == true)
		{
			CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

			if (CGPDFDictionaryGetDictionary(namesDictionary, "Dests", &destsDictionary) == true)
			{
				const char *destinationName = (const char *)CGPDFStringGetBytePtr(destName); // Name

				destArray = [self destinationWithName:destinationName inDestsTree:destsDictionary];
			}
		}
	}

	if (destString != NULL) // Handle a destination string
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(_PDFDocRef);

		CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Dests", &destsDictionary) == true)
		{
			CGPDFDictionaryRef targetDictionary = NULL; // Destination target dictionary

			if (CGPDFDictionaryGetDictionary(destsDictionary, destString, &targetDictionary) == true)
			{
				CGPDFDictionaryGetArray(targetDictionary, "D", &destArray);
			}
		}
	}

	if (destArray != NULL) // Handle a destination array
	{
		NSInteger targetPageNumber = 0; // The target page number

		CGPDFDictionaryRef pageDictionaryFromDestArray = NULL; // Target reference

		if (CGPDFArrayGetDictionary(destArray, 0, &pageDictionaryFromDestArray) == true)
		{
			NSInteger pageCount = CGPDFDocumentGetNumberOfPages(_PDFDocRef); // Pages

			for (NSInteger pageNumber = 1; pageNumber <= pageCount; pageNumber++)
			{
				CGPDFPageRef pageRef = CGPDFDocumentGetPage(_PDFDocRef, pageNumber);

				CGPDFDictionaryRef pageDictionaryFromPage = CGPDFPageGetDictionary(pageRef);

				if (pageDictionaryFromPage == pageDictionaryFromDestArray) // Found it
				{
					targetPageNumber = pageNumber; break;
				}
			}
		}
		else // Try page number from array possibility
		{
			CGPDFInteger pageNumber = 0; // Page number in array

			if (CGPDFArrayGetInteger(destArray, 0, &pageNumber) == true)
			{
				targetPageNumber = (pageNumber + 1); // 1-based
			}
		}

		if (targetPageNumber > 0) // We have a target page number
		{
			linkTarget = [NSNumber numberWithInteger:targetPageNumber];
		}
	}

	return linkTarget;
}

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer
{
	id result = nil; // Tap result object

	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		if (_links.count > 0) // Process the single tap
		{
			CGPoint point = [recognizer locationInView:self];

			for (ReaderDocumentLink *link in _links) // Enumerate links
			{
				if (CGRectContainsPoint(link.rect, point) == true) // Found it
				{
					result = [self annotationLinkTarget:link.dictionary]; break;
				}
			}
		}
	}

	return result;
}

#pragma mark ReaderContentPage instance methods

- (id)initWithFrame:(CGRect)frame
{
	id view = nil; // UIView

	if (CGRectIsEmpty(frame) == false)
	{
		if ((self = [super initWithFrame:frame]))
		{
			self.autoresizesSubviews = NO;
			self.userInteractionEnabled = NO;
			self.contentMode = UIViewContentModeRedraw;
			self.autoresizingMask = UIViewAutoresizingNone;
			self.backgroundColor = [UIColor clearColor];

			view = self; // Return self
		}
	}
	else // Handle invalid frame size
	{
		self = nil;
	}

	return view;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase
{
	CGRect viewRect = CGRectZero; // View rect

	if (fileURL != nil) // Check for non-nil file URL
	{
		_PDFDocRef = CGPDFDocumentCreateX((__bridge CFURLRef)fileURL, phrase);

		if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (page < 1) page = 1; // Check the lower page bounds

			NSInteger pages = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

			if (page > pages) page = pages; // Check the upper page bounds

			_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page

			if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
			{
				CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

				CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
				CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
				CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

				_pageAngle = CGPDFPageGetRotationAngle(_PDFPageRef); // Angle

				switch (_pageAngle) // Page rotation angle (in degrees)
				{
					default: // Default case
					case 0: case 180: // 0 and 180 degrees
					{
						_pageWidth = effectiveRect.size.width;
						_pageHeight = effectiveRect.size.height;
						_pageOffsetX = effectiveRect.origin.x;
						_pageOffsetY = effectiveRect.origin.y;
						break;
					}

					case 90: case 270: // 90 and 270 degrees
					{
						_pageWidth = effectiveRect.size.height;
						_pageHeight = effectiveRect.size.width;
						_pageOffsetX = effectiveRect.origin.y;
						_pageOffsetY = effectiveRect.origin.x;
						break;
					}
				}

				NSInteger page_w = _pageWidth; // Integer width
				NSInteger page_h = _pageHeight; // Integer height

				if (page_w % 2) page_w--; if (page_h % 2) page_h--; // Even

				viewRect.size = CGSizeMake(page_w, page_h); // View size
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

	id view = [self initWithFrame:viewRect]; // UIView setup

	if (view != nil) [self buildAnnotationLinksList]; // Links

	return view;
}

- (void)removeFromSuperview
{
	self.layer.delegate = nil;

	//self.layer.contents = nil;

	[super removeFromSuperview];
}

- (void)dealloc
{
	CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

	CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
}

#if (READER_DISABLE_RETINA == TRUE) // Option

- (void)didMoveToWindow
{
	self.contentScaleFactor = 1.0f; // Override scale factor
}

#endif // end of READER_DISABLE_RETINA Option

#pragma mark CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	ReaderContentPage *readerContentPage = self; // Retain self

	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White

	CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill

	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(CGContextGetClipBoundingBox(context)));

	CGContextTranslateCTM(context, 0.0f, self.bounds.size.height); CGContextScaleCTM(context, 1.0f, -1.0f);

	CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(_PDFPageRef, kCGPDFCropBox, self.bounds, 0, true));

	//CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);

	CGContextDrawPDFPage(context, _PDFPageRef); // Render the PDF page into the context

	if (readerContentPage != nil) readerContentPage = nil; // Release self
}

@end

#pragma mark -

//
//	ReaderDocumentLink class implementation
//

@implementation ReaderDocumentLink
{
	CGPDFDictionaryRef _dictionary;

	CGRect _rect;
}

#pragma mark Properties

@synthesize rect = _rect;
@synthesize dictionary = _dictionary;

#pragma mark ReaderDocumentLink class methods

+ (id)newWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
	return [[ReaderDocumentLink alloc] initWithRect:linkRect dictionary:linkDictionary];
}

#pragma mark ReaderDocumentLink instance methods

- (id)initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
	if ((self = [super init]))
	{
		_dictionary = linkDictionary;

		_rect = linkRect;
	}

	return self;
}

@end
