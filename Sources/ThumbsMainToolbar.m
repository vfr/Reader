//
//	ThumbsMainToolbar.m
//	Reader v2.3.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"

@implementation ThumbsMainToolbar

#pragma mark Constants

#define TITLE_Y 8.0f
#define TITLE_X 12.0f
#define TITLE_HEIGHT 28.0f

#define DONE_BUTTON_WIDTH 56.0f

#define SHOW_CONTROL_HEIGHT 30.0f
#define SHOW_CONTROL_WIDTH 70.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ThumbsMainToolbar instance methods

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

		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"button")
										style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];

		doneButton.width = (DONE_BUTTON_WIDTH - 8.0f); titleX += DONE_BUTTON_WIDTH; titleWidth -= DONE_BUTTON_WIDTH;

		[toolbarItems addObject:doneButton]; [doneButton release];

#if (READER_BOOKMARKS == TRUE) // Option

		UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

		[toolbarItems addObject:flexSpace]; [flexSpace release];

		UIImage *thumbsImage = [UIImage imageNamed:@"Reader-Thumbs.png"];
		UIImage *bookmarkImage = [UIImage imageNamed:@"Reader-Mark-Y.png"];
		NSArray *buttonItems = [NSArray arrayWithObjects:thumbsImage, bookmarkImage, nil];

		UISegmentedControl *showControl = [[UISegmentedControl alloc] initWithItems:buttonItems];

		showControl.frame = CGRectMake(0.0f, 0.0f, SHOW_CONTROL_WIDTH, SHOW_CONTROL_HEIGHT);
		showControl.segmentedControlStyle = UISegmentedControlStyleBordered;
		showControl.selectedSegmentIndex = 0; // Default segment index
		showControl.autoresizingMask = UIViewAutoresizingNone;
		showControl.backgroundColor = [UIColor clearColor];

		[showControl addTarget:self action:@selector(showControlTapped:) forControlEvents:UIControlEventValueChanged];

		UIBarButtonItem *showButton = [[UIBarButtonItem alloc] initWithCustomView:showControl]; [showControl release];

		showButton.width = SHOW_CONTROL_WIDTH; titleWidth -= (SHOW_CONTROL_WIDTH + 6.0f);

		[toolbarItems addObject:showButton]; [showButton release];

#endif // end of READER_BOOKMARKS Option

		[self setItems:toolbarItems animated:NO]; [toolbarItems release];

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

	[theTitleLabel release], theTitleLabel = nil;

	[super dealloc];
}

- (void)setToolbarTitle:(NSString *)title
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	theTitleLabel.text = title;
}

#pragma mark UISegmentedControl action methods

- (void)showControlTapped:(UISegmentedControl *)control
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self showControl:control];
}

#pragma mark UIBarButtonItem action methods

- (void)doneButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

@end
