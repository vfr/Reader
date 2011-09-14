//
//	ReaderMainToolbar.m
//	Reader v2.3.0
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

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"

#import <MessageUI/MessageUI.h>

@implementation ReaderMainToolbar

#pragma mark Constants

#define TITLE_Y 8.0f
#define TITLE_X 12.0f
#define TITLE_HEIGHT 28.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 44.0f
#define PRINT_BUTTON_WIDTH 44.0f
#define EMAIL_BUTTON_WIDTH 44.0f
#define MARK_BUTTON_WIDTH 44.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame title:nil];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.translucent = YES;
		self.barStyle = UIBarStyleBlack;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		NSMutableArray *toolbarItems = [NSMutableArray new]; // Toolbar items

		CGFloat titleX = TITLE_X; CGFloat titleWidth = (self.bounds.size.width - (titleX * 2.0f));

#if (READER_STANDALONE == FALSE) // Option

		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"button")
										style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];

		doneButton.width = (DONE_BUTTON_WIDTH - 8.0f); titleX += DONE_BUTTON_WIDTH; titleWidth -= DONE_BUTTON_WIDTH;

		[toolbarItems addObject:doneButton]; [doneButton release];

#endif // end of READER_STANDALONE Option

#if (READER_ENABLE_THUMBS == TRUE) // Option

		UIBarButtonItem *thumbsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Thumbs.png"]
										style:UIBarButtonItemStyleBordered target:self action:@selector(thumbsButtonTapped:)];

		thumbsButton.width = (THUMBS_BUTTON_WIDTH - 8.0f); titleX += THUMBS_BUTTON_WIDTH; titleWidth -= THUMBS_BUTTON_WIDTH;

		[toolbarItems addObject:thumbsButton]; [thumbsButton release];

#endif // end of READER_ENABLE_THUMBS Option

		UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

		[toolbarItems addObject:flexSpace]; [flexSpace release];

#if (READER_ENABLE_PRINT == TRUE) // Option

		Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

		if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
		{
			UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Print.png"]
											style:UIBarButtonItemStyleBordered target:self action:@selector(printButtonTapped:)];

			printButton.width = (PRINT_BUTTON_WIDTH - 8.0f); titleWidth -= PRINT_BUTTON_WIDTH;

			[toolbarItems addObject:printButton]; [printButton release];
		}

#endif // end of READER_ENABLE_PRINT Option

#if (READER_ENABLE_MAIL == TRUE) // Option

		if ([MFMailComposeViewController canSendMail] == YES)
		{
			UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Email.png"]
											style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonTapped:)];

			emailButton.width = (EMAIL_BUTTON_WIDTH - 8.0f); titleWidth -= EMAIL_BUTTON_WIDTH;

			[toolbarItems addObject:emailButton]; [emailButton release];
		}

#endif // end of READER_ENABLE_MAIL Option

#if (READER_BOOKMARKS == TRUE) // Option

		markButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(markButtonTapped:)];

		markButton.width = (MARK_BUTTON_WIDTH - 8.0f); titleWidth -= MARK_BUTTON_WIDTH;

		[toolbarItems addObject:markButton]; markButton.tag = NSIntegerMin;

		markImageN = [[UIImage imageNamed:@"Reader-Mark-N.png"] retain]; // N image
		markImageY = [[UIImage imageNamed:@"Reader-Mark-Y.png"] retain]; // Y image

#endif // end of READER_BOOKMARKS Option

		if (toolbarItems.count > 1) [self setItems:toolbarItems animated:NO]; [toolbarItems release];

		CGRect titleRect = CGRectMake(titleX, TITLE_Y, titleWidth, TITLE_HEIGHT);

		theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

		theTitleLabel.text = title; // Toolbar title
		theTitleLabel.textAlignment = UITextAlignmentCenter;
		theTitleLabel.font = [UIFont systemFontOfSize:20.0f];
		theTitleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
		theTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		theTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		theTitleLabel.backgroundColor = [UIColor clearColor];
		theTitleLabel.adjustsFontSizeToFitWidth = YES;
		theTitleLabel.minimumFontSize = 14.0f;

		[self addSubview:theTitleLabel];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[markButton release], markButton = nil;

	[theTitleLabel release], theTitleLabel = nil;

	[markImageN release], markImageN = nil;
	[markImageY release], markImageY = nil;

	[super dealloc];
}

- (void)setToolbarTitle:(NSString *)title
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	theTitleLabel.text = title;
}

- (void)setBookmarkState:(BOOL)state
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) markButton.image = (state ? markImageY : markImageN);

		markButton.tag = state; // Update bookmarked state tag
	}

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		markButton.image = (state ? markImageY : markImageN);
	}

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
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

- (void)showToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

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

#pragma mark UIBarButtonItem action methods

- (void)doneButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)printButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self markButton:button];
}

@end
