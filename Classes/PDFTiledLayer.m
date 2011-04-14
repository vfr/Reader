//
//	PDFTiledLayer.m
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

#import "PDFTiledLayer.h"

@implementation PDFTiledLayer

#pragma mark Constants

#define ZOOM_LEVELS 5

#pragma mark Properties

//@synthesize ;

#pragma mark PDFTiledLayer class methods

+ (CFTimeInterval)fadeDuration
{
	return 0.0; // No fading wanted
}

#pragma mark PDFTiledLayer instance methods

- (id)init
{
	if ((self = [super init]))
	{
		self.levelsOfDetail = ZOOM_LEVELS;

		self.levelsOfDetailBias = (ZOOM_LEVELS - 1);

		CGFloat screenScale; // Points to pixels

		UIScreen *mainScreen = [UIScreen mainScreen];

		if ([mainScreen respondsToSelector:@selector(scale)])
			screenScale = [mainScreen scale];
		else
			screenScale = 1.0f;

		CGRect screenBounds = [mainScreen bounds]; // Is in points

		CGFloat w_pixels = (screenBounds.size.width * screenScale);
		CGFloat h_pixels = (screenBounds.size.height * screenScale);

		CGFloat max = (w_pixels < h_pixels) ? h_pixels : w_pixels;

		CGFloat sizeOfTiles = (max < 512.0f) ? 512.0f : 1024.0f;

		self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
	}

	return self;
}

@end
