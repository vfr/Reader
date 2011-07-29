//
//	ReaderMainPagebar.m
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

#import "ReaderMainPagebar.h"
#import "ReaderDocument.h"

#import <QuartzCore/QuartzCore.h>

@implementation ReaderMainPagebar

#pragma mark Constants

#define PAGE_NUMBER_WIDTH 96.0f
#define PAGE_NUMBER_HEIGHT 30.0f

#define SLIDER_WIDTH_INSET 16.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainPagebar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.64f];

		CGFloat numberY = (0.0f - (PAGE_NUMBER_HEIGHT * 2.0f));
		CGFloat numberX = ((self.bounds.size.width - PAGE_NUMBER_WIDTH) / 2.0f);
		CGRect numberRect = CGRectMake(numberX, numberY, PAGE_NUMBER_WIDTH, PAGE_NUMBER_HEIGHT);

		pageNumberView = [[UIView alloc] initWithFrame:numberRect];

		pageNumberView.autoresizesSubviews = NO;
		pageNumberView.userInteractionEnabled = NO;
		pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		pageNumberView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];

		pageNumberView.layer.cornerRadius = 4.0f;
		pageNumberView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		pageNumberView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
		pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageNumberView.bounds].CGPath;
		pageNumberView.layer.shadowRadius = 2.0f; pageNumberView.layer.shadowOpacity = 1.0f;

		CGRect labelRect = CGRectInset(pageNumberView.bounds, 4.0f, 2.0f); // Inset the text a bit

		pageNumberLabel = [[UILabel alloc] initWithFrame:labelRect];

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

		[pageNumberView addSubview:pageNumberLabel];

		[self addSubview:pageNumberView];

		CGRect sliderFrame = CGRectInset(self.bounds, SLIDER_WIDTH_INSET, 0.0f); // Inset the slider

		thePageSlider = [[UISlider alloc] initWithFrame:sliderFrame];

		thePageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		thePageSlider.minimumValue = 1.0f; thePageSlider.maximumValue = 1.0f; thePageSlider.value = 1.0f;

		[thePageSlider addTarget:self action:@selector(pageSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
		[thePageSlider addTarget:self action:@selector(pageSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
		[thePageSlider addTarget:self action:@selector(pageSliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
		[thePageSlider addTarget:self action:@selector(pageSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:thePageSlider];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[thePageSlider release], thePageSlider = nil;

	[pageNumberLabel release], pageNumberLabel = nil;

	[pageNumberView release], pageNumberView = nil;

	[document release], document = nil;

	[super dealloc];
}

- (void)setReaderDocument:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[document release], document = nil; // Release first

	document = [object retain]; // Retain the document object

	thePageSlider.maximumValue = [document.pageCount integerValue];

	[self updatePageNumberDisplay]; // Update page display
}

- (void)updatePageNumberText:(NSInteger)pageNumber
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger pageCount = [document.pageCount integerValue];

	NSString *format = NSLocalizedString(@"%d of %d", @"format");

	NSString *numbers = [NSString stringWithFormat:format, pageNumber, pageCount];

	pageNumberLabel.text = numbers; // Update page number label text
}

- (void)updatePageNumberDisplay
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self updatePageNumberText:[document.pageNumber integerValue]]; // Update text

	thePageSlider.value = [document.pageNumber integerValue]; // Update slider
}

- (void)hidePagebar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO)
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

	if (self.hidden == YES)
	{
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

#pragma mark UISlider action methods

- (void)pageSliderTouchDown:(UISlider *)slider
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger pageNumber = slider.value; // Get page slider value

	if (pageNumber != [document.pageNumber integerValue]) // Only if different
	{
		[self updatePageNumberText:pageNumber]; // Update page number text
	}

	lastPageTrack = pageNumber; // Start tracking
}

- (void)pageSliderValueChanged:(UISlider *)slider
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger pageNumber = slider.value; // Get page slider value

	if (pageNumber != lastPageTrack) // Only if the page has changed
	{
		[self updatePageNumberText:pageNumber]; // Update page number text

		lastPageTrack = pageNumber; // Update tracking
	}
}

- (void)pageSliderTouchUp:(UISlider *)slider
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger pageNumber = slider.value; // Get page slider value

	if (pageNumber != lastPageTrack) // Only if the page has changed
	{
		[self updatePageNumberText:pageNumber]; // Update page number text

		thePageSlider.value = pageNumber; // Set slider to integer value
	}

	[delegate pagebar:self gotoPage:pageNumber]; // Goto the page

	lastPageTrack = 0; // Reset tracking
}

@end
