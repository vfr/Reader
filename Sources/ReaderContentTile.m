//
//	ReaderContentTile.m
//	Reader v2.3.0
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

#import "ReaderContentTile.h"

@implementation ReaderContentTile

#pragma mark Constants

#define LEVELS_OF_DETAIL 4
#define LEVELS_OF_DETAIL_BIAS 3

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderContentTile class methods

+ (CFTimeInterval)fadeDuration
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return 0.001; // iOS bug workaround

	//return 0.0; // No fading wanted
}

#pragma mark ReaderContentTile instance methods

- (id)init
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init]))
	{
		self.levelsOfDetail = LEVELS_OF_DETAIL;

		self.levelsOfDetailBias = LEVELS_OF_DETAIL_BIAS;

		UIScreen *mainScreen = [UIScreen mainScreen]; // Screen

		CGFloat screenScale = [mainScreen scale]; // Screen scale

		CGRect screenBounds = [mainScreen bounds]; // Screen bounds

		CGFloat w_pixels = (screenBounds.size.width * screenScale);

		CGFloat h_pixels = (screenBounds.size.height * screenScale);

		CGFloat max = (w_pixels < h_pixels) ? h_pixels : w_pixels;

		CGFloat sizeOfTiles = (max < 512.0f) ? 512.0f : 1024.0f;

		self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
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

@end
