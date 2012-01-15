//
//	ReaderDemoController.m
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
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

#import "ReaderDemoController.h"

@implementation ReaderDemoController

#pragma mark Constants

#define DEMO_VIEW_CONTROLLER_PUSH FALSE

//#pragma mark Properties

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

	self.view.backgroundColor = [UIColor clearColor]; // Transparent

	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	NSString *name = [infoDictionary objectForKey:@"CFBundleName"];

	NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];

	self.title = [NSString stringWithFormat:@"%@ v%@", name, version];

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

#endif // DEMO_VIEW_CONTROLLER_PUSH
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

#endif // DEMO_VIEW_CONTROLLER_PUSH
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

	[super dealloc];
}

#pragma mark UIGestureRecognizer methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)

	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];

	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file

	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];

	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];

		readerViewController.delegate = self; // Set the ReaderViewController delegate to self

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

		[self.navigationController pushViewController:readerViewController animated:YES];

#else // present in a modal view controller

		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;

		[self presentModalViewController:readerViewController animated:YES];

#endif // DEMO_VIEW_CONTROLLER_PUSH

		[readerViewController release]; // Release the ReaderViewController
	}
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)

	[self.navigationController popViewControllerAnimated:YES];

#else // dismiss the modal view controller

	[self dismissModalViewControllerAnimated:YES];

#endif // DEMO_VIEW_CONTROLLER_PUSH
}

@end
