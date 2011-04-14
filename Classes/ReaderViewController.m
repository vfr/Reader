//
//	ReaderViewController.m
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-01.
//	Copyright © 2010-2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderViewController.h"
#import "UtilityViewFader.h"
#import "PDFViewTiled.h"

@implementation ReaderViewController

#pragma mark Constants

#define ZOOM_AMOUNT 0.25f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

#define NAV_AREA_SIZE 48.0f

#define CURRENT_PAGE_KEY @"CurrentPage"

#define READER_DOCUMENT @"Document.pdf"

#pragma mark Properties

@synthesize openURL;

#pragma mark UIViewController methods

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -initWithNibName:");
#endif

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// Custom initialization
	}

	return self;
}
*/

/*
- (void)loadView
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -loadView");
#endif

	// Implement loadView to create a view hierarchy programmatically, without using a nib.
}
*/

- (void)viewDidLoad
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewDidLoad");
#endif

	[super viewDidLoad];

	CGRect frame = CGRectZero;
	UITapGestureRecognizer *tapGesture = nil;
	UISwipeGestureRecognizer *swipeGesture = nil;

	theScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];

	theScrollView.scrollsToTop = NO;
	theScrollView.directionalLockEnabled = YES;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.minimumZoomScale = MINIMUM_ZOOM_SCALE; theScrollView.maximumZoomScale = MAXIMUM_ZOOM_SCALE;
	theScrollView.contentSize = theScrollView.bounds.size;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1; tapGesture.numberOfTapsRequired = 1; // One finger single tap
	[self.view addGestureRecognizer:tapGesture]; [tapGesture release];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1; tapGesture.numberOfTapsRequired = 2; // One finger double tap
	[self.view addGestureRecognizer:tapGesture]; [tapGesture release];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesTwo:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 2; tapGesture.numberOfTapsRequired = 2; // Two finger double tap
	[self.view addGestureRecognizer:tapGesture]; [tapGesture release];

	swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleAllSwipes:)];
	swipeGesture.cancelsTouchesInView = NO; swipeGesture.delaysTouchesEnded = NO; swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft; // ++page
	[self.view addGestureRecognizer:swipeGesture]; [swipeGesture release];

	swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleAllSwipes:)];
	swipeGesture.cancelsTouchesInView = NO; swipeGesture.delaysTouchesEnded = NO; swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight; // --page
	[self.view addGestureRecognizer:swipeGesture]; [swipeGesture release];

	NSInteger page = 1; NSURL *fileURL = openURL;

	if (fileURL == nil) // Open the bundled PDF if a file URL to an 'Open In...' PDF was not provided
	{
		fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:READER_DOCUMENT ofType:nil]];

		page = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_PAGE_KEY];
	}

	thePDFView = [[PDFViewTiled alloc] initWithURL:fileURL page:page password:nil frame:theScrollView.bounds];

	[theScrollView addSubview:thePDFView];

	theToolbar = [UIToolbar new]; // Create the application toolbar

	theToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theToolbar.barStyle = UIBarStyleBlack; theToolbar.translucent = YES;

	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight]; [infoButton sizeToFit];

	[infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *barInfoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton]; // Use the UIButton view

	UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

	theToolbar.items = [NSArray arrayWithObjects:flexiSpace, barInfoButton, nil];

	[barInfoButton release]; [flexiSpace release]; // Cleanup

	[self.view addSubview:theToolbar]; [theToolbar sizeToFit];

	frame = theToolbar.bounds;
	frame.origin.y += 4.0f; frame.size.height -= 8.0f;
	frame.origin.x += 8.0f; frame.size.width -= 48.0f;

	theLabel = [[UILabel alloc] initWithFrame:frame];

	theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theLabel.backgroundColor = [UIColor clearColor];
	theLabel.lineBreakMode = UILineBreakModeCharacterWrap;
	theLabel.textAlignment = UITextAlignmentCenter;
	theLabel.textColor = [UIColor whiteColor];
	theLabel.text = [[fileURL path] lastPathComponent];

	[theToolbar addSubview:theLabel];

	toolbarFader = [[UtilityViewFader alloc] initWithView:theToolbar];

	frame.origin.x = self.view.bounds.origin.x;
	frame.origin.y = (self.view.bounds.size.height - theToolbar.frame.size.height);
	frame.size.height = theToolbar.frame.size.height;
	frame.size.width = self.view.bounds.size.width;

	thePagebar = [[UIView alloc] initWithFrame:frame]; // Create the page navigation bar

	thePagebar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	thePagebar.backgroundColor = [UIColor colorWithRed:0.75f green:0.0f blue:0.0f alpha:0.5f];
	thePagebar.hidden = YES; thePagebar.alpha = 0.0f;

	[self.view addSubview:thePagebar];

	pagebarFader = [[UtilityViewFader alloc] initWithView:thePagebar];

	frame = thePagebar.bounds;
	frame.origin.y += 4.0f; frame.size.height -= 8.0f;
	frame.origin.x += 6.0f; frame.size.width -= 12.0f;

	theSlider = [[UISlider alloc] initWithFrame:frame];

	theSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theSlider.minimumValue = 1.0f; theSlider.maximumValue = [thePDFView pageCount];
	theSlider.value = [thePDFView currentPage];

	[theSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
	[theSlider addTarget:self action:@selector(sliderTouchCancel:) forControlEvents:UIControlEventTouchCancel];
//	[theSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[theSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
	[theSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];

	[thePagebar addSubview:theSlider];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewWillAppear:");
#endif

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewDidAppear:");
	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidAppear:animated];

	[toolbarFader startFadeOutTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewWillDisappear:");
#endif

	[super viewWillDisappear:animated];

	[toolbarFader stopFadeOutTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewDidDisappear:");
#endif

	[super viewDidDisappear:animated];

	if (openURL == nil) // Remember the last page only for the bundled PDF
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

		[userDefaults setInteger:thePDFView.currentPage forKey:@"CurrentPage"];

		[userDefaults synchronize]; // Ensure defaults save
	}
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewDidUnload");
#endif

	[super viewDidUnload];

	[toolbarFader release], toolbarFader = nil;
	[pagebarFader release], pagebarFader = nil;
	[theScrollView release], theScrollView = nil;
	[thePDFView release], thePDFView = nil;
	[theToolbar release], theToolbar = nil;
	[thePagebar release], thePagebar = nil;
	[theSlider release], theSlider = nil;
	[theLabel release], theLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef DEBUG
//	NSLog(@"ReaderViewController.m -shouldAutorotateToInterfaceOrientation: [%d]", interfaceOrientation);
#endif

	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUG
//	NSLog(@"ReaderViewController.m -willRotateToInterfaceOrientation: [%d]", toInterfaceOrientation);
//	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUG
//	NSLog(@"ReaderViewController.m -willAnimateRotationToInterfaceOrientation: [%d]", interfaceOrientation);
//	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif

	CGFloat zoomScale = theScrollView.zoomScale;
	CGSize contentSize = theScrollView.bounds.size;
	contentSize.width *= zoomScale; contentSize.height *= zoomScale;
	[theScrollView setContentSize:contentSize];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef DEBUG
//	NSLog(@"ReaderViewController.m -didRotateFromInterfaceOrientation: [%d] to [%d]", fromInterfaceOrientation, self.interfaceOrientation);
//	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif

	//if (fromInterfaceOrientation == self.interfaceOrientation) return; // You get this when presented modally
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -didReceiveMemoryWarning");
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -dealloc");
#endif

	[openURL release];
	[toolbarFader release];
	[pagebarFader release];
	[theScrollView release];
	[thePDFView release];
	[theToolbar release];
	[thePagebar release];
	[theSlider release];
	[theLabel release];

	[super dealloc];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return thePDFView;
}

#pragma mark UIGestureRecognizer action methods

- (void)handleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
	if (thePagebar.hidden && (theScrollView.zoomScale == NO_ZOOM_SCALE))
	{
		if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
		{
			[thePDFView incrementPage];
			theSlider.value = thePDFView.currentPage;
			return;
		}

		if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
		{
			[thePDFView decrementPage];
			theSlider.value = thePDFView.currentPage;
			return;
		}
	}
}

- (void)handleTouchesOne:(UITapGestureRecognizer *)recognizer
{
	CGRect tapAreaRect = CGRectZero;
	CGRect viewBounds = recognizer.view.bounds;
	CGPoint tapLocation = [recognizer locationInView:recognizer.view];
	NSInteger numberOfTaps = recognizer.numberOfTapsRequired;

	// Page increment (single or double tap)

	tapAreaRect.size.width = NAV_AREA_SIZE;
	tapAreaRect.origin.y = (viewBounds.origin.y + NAV_AREA_SIZE);
	tapAreaRect.origin.x = (viewBounds.size.width - NAV_AREA_SIZE);
	tapAreaRect.size.height = (viewBounds.size.height - NAV_AREA_SIZE);

	if (CGRectContainsPoint(tapAreaRect, tapLocation))
	{
		[thePDFView incrementPage];
		theSlider.value = thePDFView.currentPage;
		return;
	}

	// Page decrement (single or double tap)

	tapAreaRect.size.width = NAV_AREA_SIZE;
	tapAreaRect.origin.x = viewBounds.origin.x;
	tapAreaRect.origin.y = (viewBounds.origin.y + NAV_AREA_SIZE);
	tapAreaRect.size.height = (viewBounds.size.height - NAV_AREA_SIZE);

	if (CGRectContainsPoint(tapAreaRect, tapLocation))
	{
		[thePDFView decrementPage];
		theSlider.value = thePDFView.currentPage;
		return;
	}

	if (numberOfTaps == 1) // Reader toolbar (single tap)
	{
		tapAreaRect.size.height = NAV_AREA_SIZE;
		tapAreaRect.origin.x = viewBounds.origin.x;
		tapAreaRect.origin.y = viewBounds.origin.y;
		tapAreaRect.size.width = viewBounds.size.width;

		if (CGRectContainsPoint(tapAreaRect, tapLocation))
		{
			[toolbarFader startViewFadeIn]; return;
		}

		if (thePDFView.pageCount > 1) // Document navigation (single tap)
		{
			tapAreaRect.origin.x = NAV_AREA_SIZE;
			tapAreaRect.size.height = NAV_AREA_SIZE;
			tapAreaRect.origin.y = (viewBounds.size.height - NAV_AREA_SIZE);
			tapAreaRect.size.width = (viewBounds.size.width - (NAV_AREA_SIZE * 2.0f));

			if (CGRectContainsPoint(tapAreaRect, tapLocation))
			{
				[pagebarFader startViewFadeIn]; return;
			}
		}
	}

	if (numberOfTaps == 2)	// Zoom area handling (double tap)
	{
		tapAreaRect = CGRectInset(viewBounds, NAV_AREA_SIZE, NAV_AREA_SIZE);

		if (CGRectContainsPoint(tapAreaRect, tapLocation))
		{
			CGFloat zoomScale = theScrollView.zoomScale;

			if (zoomScale < MAXIMUM_ZOOM_SCALE) // Zoom in if below maximum zoom scale
			{
				zoomScale = ((zoomScale += ZOOM_AMOUNT) > MAXIMUM_ZOOM_SCALE) ? MAXIMUM_ZOOM_SCALE : zoomScale;

				[theScrollView setZoomScale:zoomScale animated:YES];
			}
		}
	}
}

- (void)handleTouchesTwo:(UITapGestureRecognizer *)recognizer
{
	CGRect viewBounds = recognizer.view.bounds;
	CGPoint tapLocation = [recognizer locationInView:recognizer.view];

	CGRect tapAreaRect = CGRectInset(viewBounds, NAV_AREA_SIZE, NAV_AREA_SIZE);

	if (CGRectContainsPoint(tapAreaRect, tapLocation))
	{
		CGFloat zoomScale = theScrollView.zoomScale;

		if (zoomScale > MINIMUM_ZOOM_SCALE) // Zoom out if above minimum zoom scale
		{
			zoomScale = ((zoomScale -= ZOOM_AMOUNT) < MINIMUM_ZOOM_SCALE) ? MINIMUM_ZOOM_SCALE : zoomScale;

			[theScrollView setZoomScale:zoomScale animated:YES];
		}
	}
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)this shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)that
{
	if ([this isMemberOfClass:[UISwipeGestureRecognizer class]])
		return YES;
	else
		return NO;
}

#pragma mark UIBarButtonItem action methods

- (void)infoButtonTapped:(UIBarButtonItem *)item
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; // App version number

	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ReaderVersion", @"Reader version format text"), version];

	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"Information text") message:message
							delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];

	[theAlert show]; [theAlert release];
}

#pragma mark UISlider action methods

- (void)sliderTouchDown:(UISlider *)slider
{
	[pagebarFader stopFadeOutTimer];
}

- (void)sliderTouchCancel:(UISlider *)slider
{
	[pagebarFader startFadeOutTimer];
}

- (void)sliderValueChanged:(UISlider *)slider
{
//	NSLog(@"slider.value = %f", slider.value);
}

- (void)sliderTouchUp:(UISlider *)slider
{
	if (slider.state == UIControlStateNormal)
	{
		[thePDFView gotoPage:slider.value];

		[pagebarFader startFadeOutTimer];
	}
}

@end
