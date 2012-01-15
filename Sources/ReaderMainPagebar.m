//
//	ReaderMainPagebar.m
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-09-01.
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

#import "ReaderMainPagebar.h"
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"

#import <QuartzCore/QuartzCore.h>

@implementation ReaderMainPagebar

#pragma mark Constants

#define THUMB_SMALL_GAP 2
#define THUMB_SMALL_WIDTH 22
#define THUMB_SMALL_HEIGHT 28

#define THUMB_LARGE_WIDTH 32
#define THUMB_LARGE_HEIGHT 42

#define PAGE_NUMBER_WIDTH 96.0f
#define PAGE_NUMBER_HEIGHT 30.0f
#define PAGE_NUMBER_SPACE 20.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainPagebar class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [CAGradientLayer class];
}

#pragma mark ReaderMainPagebar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame document:nil];
}

- (void)updatePageThumbView:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger pages = [document.pageCount integerValue];

	if (pages > 1) // Only update frame if more than one page
	{
		CGFloat controlWidth = trackControl.bounds.size.width;

		CGFloat useableWidth = (controlWidth - THUMB_LARGE_WIDTH);

		CGFloat stride = (useableWidth / (pages - 1)); // Page stride

		NSInteger X = (stride * (page - 1)); CGFloat pageThumbX = X;

		CGRect pageThumbRect = pageThumbView.frame; // Current frame

		if (pageThumbX != pageThumbRect.origin.x) // Only if different
		{
			pageThumbRect.origin.x = pageThumbX; // The new X position

			pageThumbView.frame = pageThumbRect; // Update the frame
		}
	}

	if (page != pageThumbView.tag) // Only if page number changed
	{
		pageThumbView.tag = page; [pageThumbView reuse]; // Reuse the thumb view

		CGSize size = CGSizeMake(THUMB_LARGE_WIDTH, THUMB_LARGE_HEIGHT); // Maximum thumb size

		NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password;

		ReaderThumbRequest *request = [ReaderThumbRequest forView:pageThumbView fileURL:fileURL password:phrase guid:guid page:page size:size];

		UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:request priority:YES]; // Request the thumb

		UIImage *thumb = ([image isKindOfClass:[UIImage class]] ? image : nil); [pageThumbView showImage:thumb];
	}
}

- (void)updatePageNumberText:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (page != pageNumberLabel.tag) // Only if page number changed
	{
		NSInteger pages = [document.pageCount integerValue]; // Total pages

		NSString *format = NSLocalizedString(@"%d of %d", @"format"); // Format

		NSString *number = [NSString stringWithFormat:format, page, pages]; // Text

		pageNumberLabel.text = number; // Update the page number label text

		pageNumberLabel.tag = page; // Update the last page number tag
	}
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(object != nil); // Check

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		CGColorRef liteColor = [UIColor colorWithWhite:0.82f alpha:0.8f].CGColor;
		CGColorRef darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f].CGColor;
		layer.colors = [NSArray arrayWithObjects:(id)liteColor, (id)darkColor, nil];

		CGRect shadowRect = self.bounds; shadowRect.size.height = 4.0f; shadowRect.origin.y -= shadowRect.size.height;

		ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];

		[self addSubview:shadowView]; [shadowView release]; // Add the shadow to the view

		CGFloat numberY = (0.0f - (PAGE_NUMBER_HEIGHT + PAGE_NUMBER_SPACE));
		CGFloat numberX = ((self.bounds.size.width - PAGE_NUMBER_WIDTH) / 2.0f);
		CGRect numberRect = CGRectMake(numberX, numberY, PAGE_NUMBER_WIDTH, PAGE_NUMBER_HEIGHT);

		pageNumberView = [[UIView alloc] initWithFrame:numberRect]; // Page numbers view

		pageNumberView.autoresizesSubviews = NO;
		pageNumberView.userInteractionEnabled = NO;
		pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		pageNumberView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];

		//pageNumberView.layer.cornerRadius = 4.0f;
		pageNumberView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		pageNumberView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
		pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageNumberView.bounds].CGPath;
		pageNumberView.layer.shadowRadius = 2.0f; pageNumberView.layer.shadowOpacity = 1.0f;

		CGRect textRect = CGRectInset(pageNumberView.bounds, 4.0f, 2.0f); // Inset the text a bit

		pageNumberLabel = [[UILabel alloc] initWithFrame:textRect]; // Page numbers label

		pageNumberLabel.autoresizesSubviews = NO;
		pageNumberLabel.autoresizingMask = UIViewAutoresizingNone;
		pageNumberLabel.textAlignment = UITextAlignmentCenter;
		pageNumberLabel.backgroundColor = [UIColor clearColor];
		pageNumberLabel.textColor = [UIColor whiteColor];
		pageNumberLabel.font = [UIFont systemFontOfSize:16.0f];
		pageNumberLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		pageNumberLabel.shadowColor = [UIColor blackColor];
		pageNumberLabel.adjustsFontSizeToFitWidth = YES;
		pageNumberLabel.minimumFontSize = 12.0f;

		[pageNumberView addSubview:pageNumberLabel]; // Add label view

		[self addSubview:pageNumberView]; // Add page numbers display view

		trackControl = [[ReaderTrackControl alloc] initWithFrame:self.bounds]; // Track control view

		[trackControl addTarget:self action:@selector(trackViewTouchDown:) forControlEvents:UIControlEventTouchDown];
		[trackControl addTarget:self action:@selector(trackViewValueChanged:) forControlEvents:UIControlEventValueChanged];
		[trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
		[trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:trackControl]; // Add the track control and thumbs view

		document = [object retain]; // Retain the document object for our use

		[self updatePageNumberText:[document.pageNumber integerValue]];

		miniThumbViews = [NSMutableDictionary new]; // Small thumbs
	}

	return self;
}

- (void)removeFromSuperview
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[trackTimer invalidate]; [enableTimer invalidate];

	[super removeFromSuperview];
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[trackTimer release], trackTimer = nil;

	[enableTimer release], enableTimer = nil;

	[trackControl release], trackControl = nil;

	[miniThumbViews release], miniThumbViews = nil;

	[pageNumberLabel release], pageNumberLabel = nil;

	[pageNumberView release], pageNumberView = nil;

	[pageThumbView release], pageThumbView = nil;

	[document release], document = nil;

	[super dealloc];
}

- (void)layoutSubviews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGRect controlRect = CGRectInset(self.bounds, 4.0f, 0.0f);

	CGFloat thumbWidth = (THUMB_SMALL_WIDTH + THUMB_SMALL_GAP);

	NSInteger thumbs = (controlRect.size.width / thumbWidth);

	NSInteger pages = [document.pageCount integerValue]; // Pages

	if (thumbs > pages) thumbs = pages; // No more than total pages

	CGFloat controlWidth = ((thumbs * thumbWidth) - THUMB_SMALL_GAP);

	controlRect.size.width = controlWidth; // Update control width

	CGFloat widthDelta = (self.bounds.size.width - controlWidth);

	NSInteger X = (widthDelta / 2.0f); controlRect.origin.x = X;

	trackControl.frame = controlRect; // Update track control frame

	if (pageThumbView == nil) // Create the page thumb view when needed
	{
		CGFloat heightDelta = (controlRect.size.height - THUMB_LARGE_HEIGHT);

		NSInteger thumbY = (heightDelta / 2.0f); NSInteger thumbX = 0; // Thumb X, Y

		CGRect thumbRect = CGRectMake(thumbX, thumbY, THUMB_LARGE_WIDTH, THUMB_LARGE_HEIGHT);

		pageThumbView = [[ReaderPagebarThumb alloc] initWithFrame:thumbRect]; // Create the thumb view

		pageThumbView.layer.zPosition = 1.0f; // Z position so that it sits on top of the small thumbs

		[trackControl addSubview:pageThumbView]; // Add as the first subview of the track control
	}

	[self updatePageThumbView:[document.pageNumber integerValue]]; // Update page thumb view

	NSInteger strideThumbs = (thumbs - 1); if (strideThumbs < 1) strideThumbs = 1;

	CGFloat stride = ((CGFloat)pages / (CGFloat)strideThumbs); // Page stride

	CGFloat heightDelta = (controlRect.size.height - THUMB_SMALL_HEIGHT);

	NSInteger thumbY = (heightDelta / 2.0f); NSInteger thumbX = 0; // Initial X, Y

	CGRect thumbRect = CGRectMake(thumbX, thumbY, THUMB_SMALL_WIDTH, THUMB_SMALL_HEIGHT);

	NSMutableDictionary *thumbsToHide = [[miniThumbViews mutableCopy] autorelease];

	for (NSInteger thumb = 0; thumb < thumbs; thumb++) // Iterate through needed thumbs
	{
		NSInteger page = ((stride * thumb) + 1); if (page > pages) page = pages; // Page

		NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key for thumb view

		ReaderPagebarThumb *smallThumbView = [miniThumbViews objectForKey:key]; // Thumb view

		if (smallThumbView == nil) // We need to create a new small thumb view for the page number
		{
			CGSize size = CGSizeMake(THUMB_SMALL_WIDTH, THUMB_SMALL_HEIGHT); // Maximum thumb size

			NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password;

			smallThumbView = [[ReaderPagebarThumb alloc] initWithFrame:thumbRect small:YES]; // Create a small thumb view

			ReaderThumbRequest *thumbRequest = [ReaderThumbRequest forView:smallThumbView fileURL:fileURL password:phrase guid:guid page:page size:size];

			UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:NO]; // Request the thumb

			if ([image isKindOfClass:[UIImage class]]) [smallThumbView showImage:image]; // Use thumb image from cache

			[trackControl addSubview:smallThumbView]; [miniThumbViews setObject:smallThumbView forKey:key];

			[smallThumbView release], smallThumbView = nil; // Cleanup
		}
		else // Resue existing small thumb view for the page number
		{
			smallThumbView.hidden = NO; [thumbsToHide removeObjectForKey:key];

			if (CGRectEqualToRect(smallThumbView.frame, thumbRect) == false)
			{
				smallThumbView.frame = thumbRect; // Update thumb frame
			}
		}

		thumbRect.origin.x += thumbWidth; // Next thumb X position
	}

	[thumbsToHide enumerateKeysAndObjectsUsingBlock: // Hide unused thumbs
		^(id key, id object, BOOL *stop)
		{
			ReaderPagebarThumb *thumb = object; thumb.hidden = YES;
		}
	];
}

- (void)updatePagebarViews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = [document.pageNumber integerValue]; // #

	[self updatePageNumberText:page]; // Update page number text

	[self updatePageThumbView:page]; // Update page thumb view
}

- (void)updatePagebar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO) // Only if visible
	{
		[self updatePagebarViews]; // Update views
	}
}

- (void)hidePagebar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO) // Only if visible
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showPagebar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES) // Only if hidden
	{
		[self updatePagebarViews]; // Update views first

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark ReaderTrackControl action methods

- (void)trackTimerFired:(NSTimer *)timer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[trackTimer invalidate]; [trackTimer release], trackTimer = nil; // Cleanup

	if (trackControl.tag != [document.pageNumber integerValue]) // Only if different
	{
		[delegate pagebar:self gotoPage:trackControl.tag]; // Go to document page
	}
}

- (void)enableTimerFired:(NSTimer *)timer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[enableTimer invalidate]; [enableTimer release], enableTimer = nil; // Cleanup

	trackControl.userInteractionEnabled = YES; // Enable track control interaction
}

- (void)restartTrackTimer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (trackTimer != nil) { [trackTimer invalidate]; [trackTimer release], trackTimer = nil; } // Invalidate and release previous timer

	trackTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(trackTimerFired:) userInfo:nil repeats:NO] retain];
}

- (void)startEnableTimer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (enableTimer != nil) { [enableTimer invalidate]; [enableTimer release], enableTimer = nil; } // Invalidate and release previous timer

	enableTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(enableTimerFired:) userInfo:nil repeats:NO] retain];
}

- (NSInteger)trackViewPageNumber:(ReaderTrackControl *)trackView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGFloat controlWidth = trackView.bounds.size.width; // View width

	CGFloat stride = (controlWidth / [document.pageCount integerValue]);

	NSInteger page = (trackView.value / stride); // Integer page number

	return (page + 1); // + 1
}

- (void)trackViewTouchDown:(ReaderTrackControl *)trackView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = [self trackViewPageNumber:trackView]; // Page

	if (page != [document.pageNumber integerValue]) // Only if different
	{
		[self updatePageNumberText:page]; // Update page number text

		[self updatePageThumbView:page]; // Update page thumb view

		[self restartTrackTimer]; // Start the track timer
	}

	trackView.tag = page; // Start page tracking
}

- (void)trackViewValueChanged:(ReaderTrackControl *)trackView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = [self trackViewPageNumber:trackView]; // Page

	if (page != trackView.tag) // Only if the page number has changed
	{
		[self updatePageNumberText:page]; // Update page number text

		[self updatePageThumbView:page]; // Update page thumb view

		trackView.tag = page; // Update the page tracking tag

		[self restartTrackTimer]; // Restart the track timer
	}
}

- (void)trackViewTouchUp:(ReaderTrackControl *)trackView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[trackTimer invalidate]; [trackTimer release], trackTimer = nil; // Cleanup

	if (trackView.tag != [document.pageNumber integerValue]) // Only if different
	{
		trackView.userInteractionEnabled = NO; // Disable track control interaction

		[delegate pagebar:self gotoPage:trackView.tag]; // Go to document page

		[self startEnableTimer]; // Start track control enable timer
	}

	trackView.tag = 0; // Reset page tracking
}

@end

#pragma mark -

//
//	ReaderTrackControl class implementation
//

@implementation ReaderTrackControl

#pragma mark Properties

@synthesize value = _value;

#pragma mark ReaderTrackControl instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super dealloc];
}

- (CGFloat)limitValue:(CGFloat)valueX
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGFloat minX = self.bounds.origin.x; // 0.0f;
	CGFloat maxX = (self.bounds.size.width - 1.0f);

	if (valueX < minX) valueX = minX; // Minimum X
	if (valueX > maxX) valueX = maxX; // Maximum X

	return valueX;
}

#pragma mark UIControl subclass methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPoint point = [touch locationInView:self]; // Touch point

	_value = [self limitValue:point.x]; // Limit control value

	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.touchInside == YES) // Only if inside the control
	{
		CGPoint point = [touch locationInView:touch.view]; // Touch point

		CGFloat x = [self limitValue:point.x]; // Potential new control value

		if (x != _value) // Only if the new value has changed since the last time
		{
			_value = x; [self sendActionsForControlEvents:UIControlEventValueChanged];
		}
	}

	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPoint point = [touch locationInView:self]; // Touch point

	_value = [self limitValue:point.x]; // Limit control value
}

@end

#pragma mark -

//
//	ReaderPagebarThumb class implementation
//

@implementation ReaderPagebarThumb

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderPagebarThumb instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame small:NO];
}

- (id)initWithFrame:(CGRect)frame small:(BOOL)small
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame])) // Superclass init
	{
		CGFloat value = (small ? 0.6f : 0.7f); // Size based alpha value

		UIColor *background = [UIColor colorWithWhite:0.8f alpha:value];

		self.backgroundColor = background; imageView.backgroundColor = background;

		imageView.layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.6f].CGColor;

		imageView.layer.borderWidth = 1.0f; // Give the thumb image view a border
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super dealloc];
}

@end

#pragma mark -

//
//	ReaderPagebarShadow class implementation
//

@implementation ReaderPagebarShadow

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderPagebarShadow class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [CAGradientLayer class];
}

#pragma mark ReaderPagebarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		CGColorRef blackColor = [UIColor colorWithWhite:0.42f alpha:1.0f].CGColor;
		CGColorRef clearColor = [UIColor colorWithWhite:0.42f alpha:0.0f].CGColor;
		layer.colors = [NSArray arrayWithObjects:(id)clearColor, (id)blackColor, nil];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super dealloc];
}

@end
