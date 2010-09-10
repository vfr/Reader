//
//	ReaderAppDelegate.m
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

#import "ReaderAppDelegate.h"
#import "ReaderViewController.h"

@implementation ReaderAppDelegate

#pragma mark Properties

//@synthesize ...;

#pragma mark Miscellaneous methods

- (NSURL *)moveFileFromInboxToDocuments:(NSURL *)theURL
{
	NSURL *newURL = theURL;

	if ([theURL isFileURL] == YES) // Handle only file URLs
	{
		NSString *inboxFilePath = [theURL path]; // Convert the file URL to a file path string
		NSString *inboxPath = [inboxFilePath stringByDeletingLastPathComponent]; // ~/Documents/Inbox
		NSString *documentsPath = [inboxPath stringByDeletingLastPathComponent]; // ~/Documents

		NSString *documentFile = [inboxFilePath lastPathComponent]; // Get the actual file name
		NSString *documentFilePath = [documentsPath stringByAppendingPathComponent:documentFile];

		NSFileManager *fileManager = [[NSFileManager new] autorelease];

		if ([fileManager moveItemAtPath:inboxFilePath toPath:documentFilePath error:nil] == YES)
		{
			[fileManager removeItemAtPath:inboxPath error:nil]; // Delete the whole Inbox

			newURL = [NSURL fileURLWithPath:documentFilePath]; // Create a new file URL
		}
	}

	return newURL;
}

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -handleOpenURL:");
#endif

	return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -didFinishLaunchingWithOptions:");
#endif

	mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	mainWindow.backgroundColor = [UIColor whiteColor]; // White prevents redraw flicker

	mainViewController = [[ReaderViewController alloc] initWithNibName:nil bundle:nil];

	if (launchOptions != nil) // Check for launch options and handle the URL key
	{
		NSURL *theURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];

		if (theURL != nil) mainViewController.openURL = [self moveFileFromInboxToDocuments:theURL];
	}

	[mainWindow addSubview:mainViewController.view];

	[mainWindow makeKeyAndVisible];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationWillResignActive:");
#endif

	// Sent when the application is about to move from active to inactive state. This can occur for certain types of
	// temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
	// and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers,
	// and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationDidEnterBackground:");
#endif

	// Use this method to release shared resources, save user data, invalidate timers, and store enough
	// application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationWillEnterForeground:");
#endif

	// Called as part of transition from the background to the inactive state: here you can undo many
	// of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationDidBecomeActive:");
#endif

	// Restart any tasks that were paused (or not yet started) while the application was inactive.
	// If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationWillTerminate:");
#endif

	// Called when the application is about to terminate.
	// See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -applicationDidReceiveMemoryWarning:");
#endif

	// Free up as much memory as possible by purging cached data objects that can be recreated
	// (or reloaded from disk) later.
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"ReaderAppDelegate.m -dealloc");
#endif

	[mainViewController release];

	[mainWindow release];

	[super dealloc];
}

@end
