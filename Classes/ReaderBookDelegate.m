//
//	ReaderBookDelegate.m
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

#import "ReaderBookDelegate.h"

@implementation ReaderBookDelegate

//#pragma mark Properties

//@synthesize ;

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

	mainWindow.backgroundColor = [UIColor scrollViewTexturedBackgroundColor]; // Window background color

	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)

	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];

	NSString *documentName = [[pdfs lastObject] lastPathComponent]; assert(documentName != nil);

	ReaderDocument *document = [ReaderDocument unarchiveFromFileName:documentName password:phrase];

	if (document == nil) // We need to create a brand new ReaderDocument object the first time we run
	{
		NSString *filePath = [[NSBundle mainBundle] pathForResource:documentName ofType:nil]; // Path

		document = [[[ReaderDocument alloc] initWithFilePath:filePath password:phrase] autorelease];
	}

	if (document != nil) // Must have a valid ReaderDocument object in order to proceed
	{
		readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];

		readerViewController.delegate = self; // Set the ReaderViewController delegate to self

		mainWindow.rootViewController = readerViewController; // Set the root view controller
	}

	[mainWindow makeKeyAndVisible];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Sent when the application is about to move from active to inactive state. This can occur for certain types of
	// temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
	// and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers,
	// and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Use this method to release shared resources, save user data, invalidate timers, and store enough
	// application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Called as part of transition from the background to the inactive state: here you can undo many
	// of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Restart any tasks that were paused (or not yet started) while the application was inactive.
	// If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Called when the application is about to terminate.
	// See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Free up as much memory as possible by purging cached data objects that can be recreated
	// (or reloaded from disk) later.
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[readerViewController release], readerViewController = nil;

	[mainWindow release], mainWindow = nil;

	[super dealloc];
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Do nothing
}

@end
