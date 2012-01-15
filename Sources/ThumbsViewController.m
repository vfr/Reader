//
//	ThumbsViewController.m
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
			updateBookmarked = YES; bookmarked = [NSMutableArray new]; // Bookmarked pages

			document = [object retain]; // Retain the ReaderDocument object for our use

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

	NSString *toolbarTitle = [document.fileName stringByDeletingPathExtension];

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

	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

	NSInteger thumbSize = (large ? PAGE_THUMB_LARGE : PAGE_THUMB_SMALL); // Thumb dimensions

	[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillAppear:animated];

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
			showBookmarked = NO; // Show all thumbs

			markedOffset = [theThumbsView insetContentOffset];

			[theThumbsView reloadThumbsContentOffset:thumbsOffset];

			break; // We're done
		}

		case 1: // Show bookmarked thumbs
		{
			showBookmarked = YES; // Only bookmarked

			thumbsOffset = [theThumbsView insetContentOffset];

			if (updateBookmarked == YES) // Update bookmarked list
			{
				[bookmarked removeAllObjects]; // Empty the list first

				[document.bookmarks enumerateIndexesUsingBlock: // Enumerate
					^(NSUInteger page, BOOL *stop)
					{
						[bookmarked addObject:[NSNumber numberWithInteger:page]];
					}
				];

				markedOffset = CGPointZero; updateBookmarked = NO; // Reset
			}

			[theThumbsView reloadThumbsContentOffset:markedOffset];

			break; // We're done
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

	return (showBookmarked ? bookmarked.count : [document.pageCount integerValue]);
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

	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

	[thumbCell showText:[NSString stringWithFormat:@"%d", page]]; // Page number place holder

	[thumbCell showBookmark:[document.bookmarks containsIndex:page]]; // Show bookmarked status

	NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password; // Document info

	ReaderThumbRequest *thumbRequest = [ReaderThumbRequest forView:thumbCell fileURL:fileURL password:phrase guid:guid page:page size:size];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail

	if ([image isKindOfClass:[UIImage class]]) [thumbCell showImage:image]; // Show image from cache
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(ThumbsPageThumb *)thumbCell forIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

	[thumbCell showBookmark:[document.bookmarks containsIndex:page]]; // Show bookmarked status
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

	[delegate thumbsViewController:self gotoPage:page]; // Show the selected page

	[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

	if ([document.bookmarks containsIndex:page]) [document.bookmarks removeIndex:page]; else [document.bookmarks addIndex:page];

	updateBookmarked = YES; [thumbsView refreshThumbWithIndex:index]; // Refresh page thumb
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

		CGFloat fontSize = (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 19.0f : 16.0f);

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

		maskView = [[UIView alloc] initWithFrame:imageView.bounds];

		maskView.hidden = YES;
		maskView.autoresizesSubviews = NO;
		maskView.userInteractionEnabled = NO;
		maskView.contentMode = UIViewContentModeRedraw;
		maskView.autoresizingMask = UIViewAutoresizingNone;
		maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];

		[imageView addSubview:maskView];

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

	[maskView release], maskView = nil;

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

	maskView.frame = imageView.bounds; backView.bounds = viewRect; backView.center = location;

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

	maskView.hidden = YES; maskView.frame = imageView.bounds; backView.frame = defaultRect;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showBookmark:(BOOL)show
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	bookMark.hidden = (show ? NO : YES);
}

- (void)showTouched:(BOOL)touched
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	maskView.hidden = (touched ? NO : YES);
}

- (void)showText:(NSString *)text
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	textLabel.text = text;
}

@end
