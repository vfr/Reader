//
//	ReaderThumbRender.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-09-01.
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

#import "ReaderThumbRender.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbView.h"
#import "CGPDFDocument.h"

#import <ImageIO/ImageIO.h>

@implementation ReaderThumbRender
{
	ReaderThumbRequest *request;
}

#pragma mark - ReaderThumbRender instance methods

- (instancetype)initWithRequest:(ReaderThumbRequest *)options
{
	if ((self = [super initWithGUID:options.guid]))
	{
		request = options;
	}

	return self;
}

- (void)cancel
{
	[super cancel]; // Cancel the operation

	request.thumbView.operation = nil; // Break retain loop

	request.thumbView = nil; // Release target thumb view on cancel

	[[ReaderThumbCache sharedInstance] removeNullForKey:request.cacheKey];
}

- (NSURL *)thumbFileURL
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSString *cachePath = [ReaderThumbCache thumbCachePathForGUID:request.guid]; // Thumb cache path

	[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];

	NSString *fileName = [[NSString alloc] initWithFormat:@"%@.png", request.thumbName]; // Thumb file name

	return [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:fileName]]; // File URL
}

- (void)main
{
	NSInteger page = request.thumbPage; NSString *password = request.password;

	CGImageRef imageRef = NULL; CFURLRef fileURL = (__bridge CFURLRef)request.fileURL;

	CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateUsingUrl(fileURL, password);

	if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
	{
		CGPDFPageRef thePDFPageRef = CGPDFDocumentGetPage(thePDFDocRef, page);

		if (thePDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
		{
			CGFloat thumb_w = request.thumbSize.width; // Maximum thumb width
			CGFloat thumb_h = request.thumbSize.height; // Maximum thumb height

			CGRect cropBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFCropBox);
			CGRect mediaBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFMediaBox);
			CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

			NSInteger pageRotate = CGPDFPageGetRotationAngle(thePDFPageRef); // Angle

			CGFloat page_w = 0.0f; CGFloat page_h = 0.0f; // Rotated page size

			switch (pageRotate) // Page rotation (in degrees)
			{
				default: // Default case
				case 0: case 180: // 0 and 180 degrees
				{
					page_w = effectiveRect.size.width;
					page_h = effectiveRect.size.height;
					break;
				}

				case 90: case 270: // 90 and 270 degrees
				{
					page_h = effectiveRect.size.width;
					page_w = effectiveRect.size.height;
					break;
				}
			}

			CGFloat scale_w = (thumb_w / page_w); // Width scale
			CGFloat scale_h = (thumb_h / page_h); // Height scale

			CGFloat scale = 0.0f; // Page to target thumb size scale

			if (page_h > page_w)
				scale = ((thumb_h > thumb_w) ? scale_w : scale_h); // Portrait
			else
				scale = ((thumb_h < thumb_w) ? scale_h : scale_w); // Landscape

			NSInteger target_w = (page_w * scale); // Integer target thumb width
			NSInteger target_h = (page_h * scale); // Integer target thumb height

			if (target_w % 2) target_w--; if (target_h % 2) target_h--; // Even

			target_w *= request.scale; target_h *= request.scale; // Screen scale

			CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB(); // RGB color space

			CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);

			CGContextRef context = CGBitmapContextCreate(NULL, target_w, target_h, 8, 0, rgb, bmi);

			if (context != NULL) // Must have a valid custom CGBitmap context to draw into
			{
				CGRect thumbRect = CGRectMake(0.0f, 0.0f, target_w, target_h); // Target thumb rect

				CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); CGContextFillRect(context, thumbRect); // White fill

				CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(thePDFPageRef, kCGPDFCropBox, thumbRect, 0, true)); // Fit rect

				//CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);

				CGContextDrawPDFPage(context, thePDFPageRef); // Render the PDF page into the custom CGBitmap context

				imageRef = CGBitmapContextCreateImage(context); // Create CGImage from custom CGBitmap context

				CGContextRelease(context); // Release custom CGBitmap context reference
			}

			CGColorSpaceRelease(rgb); // Release device RGB color space reference
		}

		CGPDFDocumentRelease(thePDFDocRef); // Release CGPDFDocumentRef reference
	}

	if (imageRef != NULL) // Create UIImage from CGImage and show it, then save thumb as PNG
	{
		UIImage *image = [UIImage imageWithCGImage:imageRef scale:request.scale orientation:UIImageOrientationUp];

		[[ReaderThumbCache sharedInstance] setObject:image forKey:request.cacheKey]; // Update cache

		if (self.isCancelled == NO) // Show the image in the target thumb view on the main thread
		{
			ReaderThumbView *thumbView = request.thumbView; // Target thumb view for image show

			NSUInteger targetTag = request.targetTag; // Target reference tag for image show

			dispatch_async(dispatch_get_main_queue(), // Queue image show on main thread
			^{
				if (thumbView.targetTag == targetTag) [thumbView showImage:image];
			});
		}

		CFURLRef thumbURL = (__bridge CFURLRef)[self thumbFileURL]; // Thumb cache path with PNG file name URL

		CGImageDestinationRef thumbRef = CGImageDestinationCreateWithURL(thumbURL, (CFStringRef)@"public.png", 1, NULL);

		if (thumbRef != NULL) // Write the thumb image file out to the thumb cache directory
		{
			CGImageDestinationAddImage(thumbRef, imageRef, NULL); // Add the image

			CGImageDestinationFinalize(thumbRef); // Finalize the image file

			CFRelease(thumbRef); // Release CGImageDestination reference
		}

		CGImageRelease(imageRef); // Release CGImage reference
	}
	else // No image - so remove the placeholder object from the cache
	{
		[[ReaderThumbCache sharedInstance] removeNullForKey:request.cacheKey];
	}

	request.thumbView.operation = nil; // Break retain loop
}

@end
