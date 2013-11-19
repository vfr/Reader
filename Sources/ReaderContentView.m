//
//	ReaderContentView.m
//	Reader v2.7.3
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
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
#import "ReaderContentView.h"
#import "ReaderContentPage.h"
#import "ReaderThumbCache.h"

#import <QuartzCore/QuartzCore.h>

@interface ReaderContentView () <UIScrollViewDelegate>

@end

@implementation ReaderContentView
{
	ReaderContentPage *theContentView;

	ReaderContentThumb *theThumbView;

	UIView *theContainerView;
}

#pragma mark Constants

#define ZOOM_FACTOR 2.0f
#define ZOOM_MAXIMUM 16.0f

#if (READER_SHOW_SHADOWS == TRUE) // Option
	#define CONTENT_INSET 4.0f
#else
	#define CONTENT_INSET 2.0f
#endif // end of READER_SHOW_SHADOWS Option

#define PAGE_THUMB_LARGE 240
#define PAGE_THUMB_SMALL 144

static void *ReaderContentViewContext = &ReaderContentViewContext;

#pragma mark Properties

@synthesize message;

#pragma mark ReaderContentView functions

static inline CGFloat ZoomScaleThatFits(CGSize target, CGSize source)
{
	CGFloat w_scale = (target.width / source.width);

	CGFloat h_scale = (target.height / source.height);

	return ((w_scale < h_scale) ? w_scale : h_scale);
}

#pragma mark ReaderContentView instance methods

- (void)updateMinimumMaximumZoom
{
	CGRect targetRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

	CGFloat zoomScale = ZoomScaleThatFits(targetRect.size, theContentView.bounds.size);

	self.minimumZoomScale = zoomScale; // Set the minimum and maximum zoom scales

	self.maximumZoomScale = (zoomScale * ZOOM_MAXIMUM); // Max number of zoom levels
}

- (id)initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page password:(NSString *)phrase
{
	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.autoresizesSubviews = NO;
		self.bouncesZoom = YES;
		self.delegate = self;

		theContentView = [[ReaderContentPage alloc] initWithURL:fileURL page:page password:phrase];

		if (theContentView != nil) // Must have a valid and initialized content view
		{
			theContainerView = [[UIView alloc] initWithFrame:theContentView.bounds];

			theContainerView.autoresizesSubviews = NO;
			theContainerView.userInteractionEnabled = NO;
			theContainerView.contentMode = UIViewContentModeRedraw;
			theContainerView.autoresizingMask = UIViewAutoresizingNone;
			theContainerView.backgroundColor = [UIColor whiteColor];

#if (READER_SHOW_SHADOWS == TRUE) // Option

			theContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
			theContainerView.layer.shadowRadius = 4.0f; theContainerView.layer.shadowOpacity = 1.0f;
			theContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:theContainerView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

			self.contentSize = theContentView.bounds.size; // Content size same as view size
			self.contentOffset = CGPointMake((0.0f - CONTENT_INSET), (0.0f - CONTENT_INSET)); // Offset
			self.contentInset = UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);

#if (READER_ENABLE_PREVIEW == TRUE) // Option

			theThumbView = [[ReaderContentThumb alloc] initWithFrame:theContentView.bounds]; // Page thumb view

			[theContainerView addSubview:theThumbView]; // Add the thumb view to the container view

#endif // end of READER_ENABLE_PREVIEW Option

			[theContainerView addSubview:theContentView]; // Add the content view to the container view

			[self addSubview:theContainerView]; // Add the container view to the scroll view

			[self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales

			self.zoomScale = self.minimumZoomScale; // Set zoom to fit page content
		}

		[self addObserver:self forKeyPath:@"frame" options:0 context:ReaderContentViewContext];

		self.tag = page; // Tag the view with the page number
	}

	return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"frame" context:ReaderContentViewContext];
}

- (void)showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase guid:(NSString *)guid
{
#if (READER_ENABLE_PREVIEW == TRUE) // Option

	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad); // Page thumb size

	CGSize size = (large ? CGSizeMake(PAGE_THUMB_LARGE, PAGE_THUMB_LARGE) : CGSizeMake(PAGE_THUMB_SMALL, PAGE_THUMB_SMALL));

	ReaderThumbRequest *request = [ReaderThumbRequest newForView:theThumbView fileURL:fileURL password:phrase guid:guid page:page size:size];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:request priority:YES]; // Request the page thumb

	if ([image isKindOfClass:[UIImage class]]) [theThumbView showImage:image]; // Show image from cache

#endif // end of READER_ENABLE_PREVIEW Option
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == ReaderContentViewContext) // Our context
	{
		if ((object == self) && [keyPath isEqualToString:@"frame"])
		{
			CGFloat oldMinimumZoomScale = self.minimumZoomScale;

			[self updateMinimumMaximumZoom]; // Update zoom scale limits

			if (self.zoomScale == oldMinimumZoomScale) // Old minimum
			{
				self.zoomScale = self.minimumZoomScale;
			}
			else // Check against minimum zoom scale
			{
				if (self.zoomScale < self.minimumZoomScale)
				{
					self.zoomScale = self.minimumZoomScale;
				}
				else // Check against maximum zoom scale
				{
					if (self.zoomScale > self.maximumZoomScale)
					{
						self.zoomScale = self.maximumZoomScale;
					}
				}
			}
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGSize boundsSize = self.bounds.size;
	CGRect viewFrame = theContainerView.frame;

	if (viewFrame.size.width < boundsSize.width)
		viewFrame.origin.x = (((boundsSize.width - viewFrame.size.width) / 2.0f) + self.contentOffset.x);
	else
		viewFrame.origin.x = 0.0f;

	if (viewFrame.size.height < boundsSize.height)
		viewFrame.origin.y = (((boundsSize.height - viewFrame.size.height) / 2.0f) + self.contentOffset.y);
	else
		viewFrame.origin.y = 0.0f;

	theContainerView.frame = viewFrame;
}

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer
{
	return [theContentView processSingleTap:recognizer];
}

- (void)zoomIncrement
{
	CGFloat zoomScale = self.zoomScale;

	if (zoomScale < self.maximumZoomScale)
	{
		zoomScale *= ZOOM_FACTOR; // Zoom in

		if (zoomScale > self.maximumZoomScale)
		{
			zoomScale = self.maximumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomDecrement
{
	CGFloat zoomScale = self.zoomScale;

	if (zoomScale > self.minimumZoomScale)
	{
		zoomScale /= ZOOM_FACTOR; // Zoom out

		if (zoomScale < self.minimumZoomScale)
		{
			zoomScale = self.minimumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomReset
{
	if (self.zoomScale > self.minimumZoomScale)
	{
		self.zoomScale = self.minimumZoomScale;
	}
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return theContainerView;
}

#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass

	[message contentView:self touchesBegan:touches]; // Message delegate
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event]; // Message superclass
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

@end

#pragma mark -

//
//	ReaderContentThumb class implementation
//

@implementation ReaderContentThumb

#pragma mark ReaderContentThumb instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) // Superclass init
	{
		imageView.contentMode = UIViewContentModeScaleAspectFill;

		imageView.clipsToBounds = YES; // Needed for aspect fill
	}

	return self;
}

@end
