//
//	ThumbsMainToolbar.m
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

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"

@implementation ThumbsMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define SHOW_CONTROL_WIDTH 78.0f

#define TITLE_HEIGHT 28.0f

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
		CGFloat viewWidth = self.bounds.size.width;

		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];

		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(BUTTON_X, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[doneButton setTitle:NSLocalizedString(@"Done", @"button") forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:doneButton];

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);

#if (READER_BOOKMARKS == TRUE) // Option

		CGFloat showControlX = (viewWidth - (SHOW_CONTROL_WIDTH + BUTTON_SPACE));

		UIImage *thumbsImage = [UIImage imageNamed:@"Reader-Thumbs.png"];
		UIImage *bookmarkImage = [UIImage imageNamed:@"Reader-Mark-Y.png"];
		NSArray *buttonItems = [NSArray arrayWithObjects:thumbsImage, bookmarkImage, nil];

		UISegmentedControl *showControl = [[UISegmentedControl alloc] initWithItems:buttonItems];

		showControl.frame = CGRectMake(showControlX, BUTTON_Y, SHOW_CONTROL_WIDTH, BUTTON_HEIGHT);
		showControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		showControl.segmentedControlStyle = UISegmentedControlStyleBar;
		showControl.tintColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
		showControl.selectedSegmentIndex = 0; // Default segment index

		[showControl addTarget:self action:@selector(showControlTapped:) forControlEvents:UIControlEventValueChanged];

		[self addSubview:showControl]; [showControl release];

		titleWidth -= (SHOW_CONTROL_WIDTH + BUTTON_SPACE);

#endif // end of READER_BOOKMARKS Option

		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f]; // 19 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
			titleLabel.text = title;

			[self addSubview:titleLabel]; [titleLabel release];
		}
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

#pragma mark UISegmentedControl action methods

- (void)showControlTapped:(UISegmentedControl *)control
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self showControl:control];
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

@end
