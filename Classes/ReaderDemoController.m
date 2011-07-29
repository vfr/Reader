//
//	ReaderDemoController.m
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

#import "ReaderDemoController.h"

@implementation ReaderDemoController

#pragma mark Constants

#define SAMPLE_DOCUMENT @"Document.pdf"

#define DEMO_VIEW_CONTROLLER_PUSH FALSE

#pragma mark Properties

//@synthesize ;

#pragma mark UIViewController methods

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
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

	self.view.backgroundColor = [UIColor clearColor]; // Clear background color

	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

	self.title = [NSString stringWithFormat:@"Reader v%@", version]; // Show app version

	CGSize viewSize = self.view.bounds.size;

	CGRect labelRect = CGRectMake(0.0f, 0.0f, 80.0f, 32.0f);

	UILabel *tapLabel = [[UILabel alloc] initWithFrame:labelRect];

	tapLabel.text = @"Tap";
	tapLabel.textColor = [UIColor whiteColor];
	tapLabel.textAlignment = UITextAlignmentCenter;
	tapLabel.backgroundColor = [UIColor clearColor];
	tapLabel.font = [UIFont systemFontOfSize:24.0f];
	tapLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	tapLabel.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	tapLabel.center = CGPointMake(viewSize.width / 2.0f, viewSize.height / 2.0f);

	[self.view addSubview:tapLabel]; [tapLabel release];

	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	//singleTap.numberOfTouchesRequired = 1; singleTap.numberOfTapsRequired = 1; //singleTap.delegate = self;
	[self.view addGestureRecognizer:singleTap]; [singleTap release];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillAppear:animated];

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController setNavigationBarHidden:NO animated:animated];

#endif
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

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController setNavigationBarHidden:YES animated:animated];

#endif
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

	[super dealloc];
}

#pragma mark UIGestureRecognizer methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	ReaderDocument *document = [ReaderDocument unarchiveFromFileName:SAMPLE_DOCUMENT];

	if (document == nil) // Create a brand new ReaderDocument object the first time we run
	{
		NSString *filePath = [[NSBundle mainBundle] pathForResource:SAMPLE_DOCUMENT ofType:nil];

		document = [[[ReaderDocument alloc] initWithFilePath:filePath password:nil] autorelease];
	}

	ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];

	readerViewController.delegate = self; // Set the ReaderViewController delegate to self

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController pushViewController:readerViewController animated:YES];

#else // present modal view controller

	readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentModalViewController:readerViewController animated:YES];

#endif

	[readerViewController release]; // Release the ReaderViewController
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController popViewControllerAnimated:YES];

#else // dismiss modal view controller

	[self dismissModalViewControllerAnimated:YES];

#endif
}

@end
