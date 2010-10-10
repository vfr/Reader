//
//	ReaderViewController.m
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-01.
//	Copyright © 2010 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderViewController.h"
#import "PDFViewTiled.h"
#import "UIViewFader.h"

@implementation ReaderViewController

#pragma mark Properties

@synthesize openURL;

#pragma mark Constants

#define ZOOM_AMOUNT 0.25f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

#define NAV_AREA_SIZE 48.0f

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
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.contentSize = self.view.bounds.size;
	theScrollView.minimumZoomScale = MINIMUM_ZOOM_SCALE;
	theScrollView.maximumZoomScale = MAXIMUM_ZOOM_SCALE;
	theScrollView.directionalLockEnabled = YES;
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO;
	tapGesture.numberOfTouchesRequired = 1; // One finger single tap
	tapGesture.numberOfTapsRequired = 1;
	//tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	[tapGesture release];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO;
	tapGesture.numberOfTouchesRequired = 1; // One finger double tap
	tapGesture.numberOfTapsRequired = 2;
	//tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	[tapGesture release];

	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesTwo:)];
	tapGesture.cancelsTouchesInView = NO; tapGesture.delaysTouchesEnded = NO;
	tapGesture.numberOfTouchesRequired = 2; // Two finger double tap
	tapGesture.numberOfTapsRequired = 2;
	//tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	[tapGesture release];

	swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleAllSwipes:)];
	swipeGesture.cancelsTouchesInView = NO; swipeGesture.delaysTouchesEnded = NO;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft; // ++page
	swipeGesture.delegate = self;
	[self.view addGestureRecognizer:swipeGesture];
	[swipeGesture release];

	swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleAllSwipes:)];
	swipeGesture.cancelsTouchesInView = NO; swipeGesture.delaysTouchesEnded = NO;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight; // --page
	swipeGesture.delegate = self;
	[self.view addGestureRecognizer:swipeGesture];
	[swipeGesture release];

	NSInteger page = 1; NSURL *fileURL = openURL;

	if (fileURL == nil) // Open the bundled PDF if a file URL to an 'Open In...' PDF was not provided
	{
		fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Document.pdf" ofType:nil]];

		page = [[NSUserDefaults standardUserDefaults] integerForKey:@"OnPage"];
	}

	thePDFView = [[PDFViewTiled alloc] initWithURL:fileURL onPage:page password:nil frame:theScrollView.bounds];

	thePDFView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[theScrollView addSubview:thePDFView];

	theToolbar = [UIToolbar new]; // Create the application toolbar

	theToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theToolbar.barStyle = UIBarStyleBlack;
	theToolbar.translucent = YES;

	UIBarButtonItem *infoButton =	[[UIBarButtonItem alloc]
									initWithImage:[UIImage imageNamed:@"Icon-Info.png"]
									style:UIBarButtonItemStylePlain
									target:self action:@selector(infoButtonTapped:)];

	infoButton.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f); // Center this graphic

	UIBarButtonItem *flexSpace =	[[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									target:nil action:NULL];

	theToolbar.items = [NSArray arrayWithObjects:flexSpace, infoButton, nil];

	[infoButton release]; [flexSpace release];

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

	toolbarFader = [[UIViewFader alloc] initWithView:theToolbar];

	frame.origin.x = self.view.bounds.origin.x;
	frame.origin.y = self.view.bounds.size.height - theToolbar.frame.size.height;
	frame.size.height = theToolbar.frame.size.height;
	frame.size.width = self.view.bounds.size.width;

	theNavbar = [[UIView alloc] initWithFrame:frame]; // Create the page navigation bar

	theNavbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	theNavbar.backgroundColor = [UIColor colorWithRed:0.75f green:0.0f blue:0.0f alpha:0.5f];
	theNavbar.hidden = YES; theNavbar.alpha = 0.0f;

	[self.view addSubview:theNavbar];

	navbarFader = [[UIViewFader alloc] initWithView:theNavbar];

	frame = theNavbar.bounds;
	frame.origin.y += 4.0f; frame.size.height -= 8.0f;
	frame.origin.x += 6.0f; frame.size.width -= 12.0f;

	theSlider = [[UISlider alloc] initWithFrame:frame];

	theSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theSlider.minimumValue = 1.0f;
	theSlider.maximumValue = [thePDFView pages];
	theSlider.value = [thePDFView page];

	[theSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
//	[theSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[theSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];

	[theNavbar addSubview:theSlider];
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

		[userDefaults setInteger:thePDFView.page forKey:@"OnPage"];

		[userDefaults synchronize]; // Ensure defaults save
	}
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -viewDidUnload");
#endif

	[super viewDidUnload];

	[navbarFader release], navbarFader = nil;
	[toolbarFader release], toolbarFader = nil;
	[theScrollView release], theScrollView = nil;
	[thePDFView release], thePDFView = nil;
	[theToolbar release], theToolbar = nil;
	[theSlider release], theSlider = nil;
	[theNavbar release], theNavbar = nil;
	[theLabel release], theLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -shouldAutorotateToInterfaceOrientation: [%d]", interfaceOrientation);
#endif

	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -willRotateToInterfaceOrientation: [%d]", toInterfaceOrientation);
	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif

	theScrollView.zoomScale = NO_ZOOM_SCALE;

	[thePDFView willRotate];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -willAnimateRotationToInterfaceOrientation: [%d]", interfaceOrientation);
	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef DEBUG
	NSLog(@"ReaderViewController.m -didRotateFromInterfaceOrientation: [%d] to [%d]", fromInterfaceOrientation, self.interfaceOrientation);
	NSLog(@" -> self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
#endif

	//if (fromInterfaceOrientation == self.interfaceOrientation) return; // You get this when presented modally

	[thePDFView didRotate];
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
	[navbarFader release];
	[toolbarFader release];
	[theScrollView release];
	[thePDFView release];
	[theToolbar release];
	[theSlider release];
	[theNavbar release];
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
	if (theNavbar.hidden && (theScrollView.zoomScale == NO_ZOOM_SCALE))
	{
		if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
		{
			[thePDFView incrementPage];
			theSlider.value = thePDFView.page;
			return;
		}

		if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
		{
			[thePDFView decrementPage];
			theSlider.value = thePDFView.page;
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
	tapAreaRect.origin.y = viewBounds.origin.y + NAV_AREA_SIZE;
	tapAreaRect.origin.x = viewBounds.size.width - NAV_AREA_SIZE;
	tapAreaRect.size.height = viewBounds.size.height - NAV_AREA_SIZE;

	if (CGRectContainsPoint(tapAreaRect, tapLocation))
	{
		[thePDFView incrementPage];
		theSlider.value = thePDFView.page;
		return;
	}

	// Page decrement (single or double tap)

	tapAreaRect.size.width = NAV_AREA_SIZE;
	tapAreaRect.origin.x = viewBounds.origin.x;
	tapAreaRect.origin.y = viewBounds.origin.y + NAV_AREA_SIZE;
	tapAreaRect.size.height = viewBounds.size.height - NAV_AREA_SIZE;

	if (CGRectContainsPoint(tapAreaRect, tapLocation))
	{
		[thePDFView decrementPage];
		theSlider.value = thePDFView.page;
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

		if (thePDFView.pages > 1) // Document navigation (single tap)
		{
			tapAreaRect.origin.x = NAV_AREA_SIZE;
			tapAreaRect.size.height = NAV_AREA_SIZE;
			tapAreaRect.origin.y = viewBounds.size.height - NAV_AREA_SIZE;
			tapAreaRect.size.width = viewBounds.size.width - (NAV_AREA_SIZE * 2);

			if (CGRectContainsPoint(tapAreaRect, tapLocation))
			{
				[navbarFader startViewFadeIn]; return;
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

	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ReaderVersion", @"Reader Version format text"), version];

	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"Information text") message:message
							delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];

	[theAlert show]; [theAlert release];
}

#pragma mark UISlider action methods

- (void)sliderTouchDown:(UISlider *)slider
{
	[navbarFader stopFadeOutTimer];
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

		[navbarFader startFadeOutTimer];
	}
}

@end
