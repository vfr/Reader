//
//	ThumbsViewController.m
//	Reader v2.4.0
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
#import "ThumbsViewController.h"
#import "ReaderThumbRequest.h"
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"

#import <QuartzCore/QuartzCore.h>

@implementation ThumbsViewController

#pragma mark Constants

#define TOOLBAR_HEIGHT 44.0f

#define PAGE_THUMB_SMALL 160
#define PAGE_THUMB_LARGE 256

#pragma mark Properties

@synthesize delegate;

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id thumbs = nil; // ThumbsViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			document = [object retain]; // Retain the supplied ReaderDocument object for our use

			thumbs = self; // Return an initialized ThumbsViewController object
		}
	}

	return thumbs;
}

/*
- (void)loadView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Implement loadView to create a view hierarchy programmatically, without using a nib.
}
*/

- (void)viewDidLoad
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidLoad];

	NSAssert(!(delegate == nil), @"delegate == nil");

	NSAssert(!(document == nil), @"ReaderDocument == nil");

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	NSString *toolbarTitle = (self.title == nil) ? [document.fileName stringByDeletingPathExtension] : self.title;

	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;

	mainToolbar = [[ThumbsMainToolbar alloc] initWithFrame:toolbarRect title:toolbarTitle]; // At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect thumbsRect = viewRect; UIEdgeInsets insets = UIEdgeInsetsZero;

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		thumbsRect.origin.y += TOOLBAR_HEIGHT; thumbsRect.size.height -= TOOLBAR_HEIGHT;
	}
	else // Set UIScrollView insets for non-UIUserInterfaceIdiomPad case
	{
		insets.top = TOOLBAR_HEIGHT;
	}

	theThumbsView = [[ReaderThumbsView alloc] initWithFrame:thumbsRect]; // Rest

	theThumbsView.contentInset = insets; theThumbsView.scrollIndicatorInsets = insets;

	theThumbsView.delegate = self;

	[self.view insertSubview:theThumbsView belowSubview:mainToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillAppear:animated];

	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

	NSInteger thumbSize = (large ? PAGE_THUMB_LARGE : PAGE_THUMB_SMALL); // Thumb dimensions

	[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device

	[theThumbsView reloadThumbsCenterOnIndex:([document.pageNumber integerValue] - 1)]; // Page
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[theThumbsView release], theThumbsView = nil;

	[mainToolbar release], mainToolbar = nil;

	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef DEBUGX
	NSLog(@"%s (%d)", __FUNCTION__, interfaceOrientation);
#endif

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // See README
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
#endif
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
#endif
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), fromInterfaceOrientation, self.interfaceOrientation);
#endif

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[bookmarked release], bookmarked = nil;

	[theThumbsView release], theThumbsView = nil;

	[mainToolbar release], mainToolbar = nil;

	[document release], document = nil;

	[super dealloc];
}

#pragma mark ThumbsMainToolbarDelegate methods

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar showControl:(UISegmentedControl *)control
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	switch (control.selectedSegmentIndex)
	{
		case 0: // Show all page thumbs
		{
			fBookmarked = NO; // Show all thumbs

			markedOffset = theThumbsView.contentOffset;

			[theThumbsView reloadThumbsContentOffset:thumbsOffset];
			break;
		}

		case 1: // Show bookmarked thumbs
		{
			fBookmarked = YES; // Only bookmarked

			thumbsOffset = theThumbsView.contentOffset;

			if (bookmarked == nil) // Create bookmarked list
			{
				bookmarked = [NSMutableArray new];

				[document.bookmarks enumerateIndexesUsingBlock:
					^(NSUInteger page, BOOL *stop)
					{
						[bookmarked addObject:[NSNumber numberWithInteger:page]];
					}
				];
			}

			[theThumbsView reloadThumbsContentOffset:markedOffset];
			break;
		}
	}
}

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar doneButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

#pragma mark UIThumbsViewDelegate methods

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return (fBookmarked ? bookmarked.count : [document.pageCount integerValue]);
}

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [[[ThumbsPageThumb alloc] initWithFrame:frame] autorelease];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(ThumbsPageThumb *)thumbCell forIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize size = [thumbCell maximumContentSize]; // Get the cell's maximum content size

	NSInteger page = fBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1);

	[thumbCell showText:[NSString stringWithFormat:@"%d", page]]; // Page number place holder

	[thumbCell showBookmark:[document.bookmarks containsIndex:page]]; // Show bookmarked status

	NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password; // Document

	ReaderThumbRequest *thumbRequest = [ReaderThumbRequest forView:thumbCell fileURL:fileURL password:phrase guid:guid page:page size:size];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail

	if ([image isKindOfClass:[UIImage class]]) [thumbCell showImage:image]; // Show image from cache
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = fBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1);

	[delegate thumbsViewController:self gotoPage:page]; // Show the selected page

	[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

@end

#pragma mark -

//
//	ThumbsPageThumb class implementation
//

@implementation ThumbsPageThumb

#pragma mark Constants

#define CONTENT_INSET 8.0f

//#pragma mark Properties

//@synthesize ;

#pragma mark ThumbsPageThumb instance methods

- (CGRect)markRectInImageView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGRect iconRect = bookMark.frame; iconRect.origin.y = (-2.0f);

	iconRect.origin.x = (imageView.bounds.size.width - bookMark.image.size.width - 8.0f);

	return iconRect; // Frame position rect inside of image view
}

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		imageView.contentMode = UIViewContentModeCenter;

		defaultRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

		maximumSize = defaultRect.size; // Maximum thumb content size

		CGFloat newWidth = ((defaultRect.size.width / 4.0f) * 3.0f);

		CGFloat offsetX = ((defaultRect.size.width - newWidth) / 2.0f);

		defaultRect.size.width = newWidth; defaultRect.origin.x += offsetX;

		imageView.frame = defaultRect; // Update the image view frame

		CGFloat fontSize = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 20.0f : 17.0f;

		textLabel = [[UILabel alloc] initWithFrame:defaultRect];

		textLabel.autoresizesSubviews = NO;
		textLabel.userInteractionEnabled = NO;
		textLabel.contentMode = UIViewContentModeRedraw;
		textLabel.autoresizingMask = UIViewAutoresizingNone;
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.font = [UIFont systemFontOfSize:fontSize];
		textLabel.textColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		textLabel.backgroundColor = [UIColor whiteColor];

		[self insertSubview:textLabel belowSubview:imageView];

		backView = [[UIView alloc] initWithFrame:defaultRect];

		backView.autoresizesSubviews = NO;
		backView.userInteractionEnabled = NO;
		backView.contentMode = UIViewContentModeRedraw;
		backView.autoresizingMask = UIViewAutoresizingNone;
		backView.backgroundColor = [UIColor whiteColor];

#if (READER_SHOW_SHADOWS == TRUE) // Option

		backView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		backView.layer.shadowRadius = 3.0f; backView.layer.shadowOpacity = 1.0f;
		backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

		[self insertSubview:backView belowSubview:textLabel];

		UIImage *image = [UIImage imageNamed:@"Reader-Mark-Y.png"];

		bookMark = [[UIImageView alloc] initWithImage:image];

		bookMark.hidden = YES;
		bookMark.autoresizesSubviews = NO;
		bookMark.userInteractionEnabled = NO;
		bookMark.contentMode = UIViewContentModeCenter;
		bookMark.autoresizingMask = UIViewAutoresizingNone;
		bookMark.frame = [self markRectInImageView];

		[imageView addSubview:bookMark];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[backView release], backView = nil;

	[textLabel release], textLabel = nil;

	[bookMark release], bookMark = nil;

	[super dealloc];
}

- (CGSize)maximumContentSize
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return maximumSize;
}

- (void)showImage:(UIImage *)image
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger x = (self.bounds.size.width / 2.0f);
	NSInteger y = (self.bounds.size.height / 2.0f);

	CGPoint location = CGPointMake(x, y); // Center point

	CGRect viewRect = CGRectZero; viewRect.size = image.size;

	textLabel.bounds = viewRect; textLabel.center = location; // Position

	imageView.bounds = viewRect; imageView.center = location; imageView.image = image;

	bookMark.frame = [self markRectInImageView]; // Position bookmark image

	backView.bounds = viewRect; backView.center = location;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)reuse
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super reuse]; // Reuse thumb view

	textLabel.text = nil; textLabel.frame = defaultRect;

	imageView.image = nil; imageView.frame = defaultRect;

	bookMark.hidden = YES; bookMark.frame = [self markRectInImageView];

	backView.frame = defaultRect; // Position background view

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showBookmark:(BOOL)show
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	bookMark.hidden = show ? NO : YES;
}

- (void)showText:(NSString *)text
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	textLabel.text = text;
}

@end
