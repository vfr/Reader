//
//	ReaderBookDelegate.h
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

#import <UIKit/UIKit.h>

#import "ReaderViewController.h"

@interface ReaderBookDelegate : NSObject <UIApplicationDelegate, ReaderViewControllerDelegate>
{
@private // Instance variables

	UIWindow *mainWindow; // Main App Window

	ReaderViewController *readerViewController;
}

@end
