//
//	UIXToolbarView.m
//	UIClass
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

#import "UIXToolbarView.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIXToolbarView

//#pragma mark Properties

//@synthesize ;

#pragma mark UIXToolbarView class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [CAGradientLayer class];
}

#pragma mark UIXToolbarView instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		CGColorRef liteColor = [UIColor colorWithWhite:0.92f alpha:0.8f].CGColor;
		CGColorRef darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f].CGColor;
		layer.colors = [NSArray arrayWithObjects:(id)liteColor, (id)darkColor, nil];

		CGRect shadowRect = self.bounds; shadowRect.origin.y += shadowRect.size.height; shadowRect.size.height = 4.0f;

		UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];

		[self addSubview:shadowView]; [shadowView release];
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

#pragma mark -

//
//	UIXToolbarShadow class implementation
//

@implementation UIXToolbarShadow

//#pragma mark Properties

//@synthesize ;

#pragma mark UIXToolbarShadow class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [CAGradientLayer class];
}

#pragma mark UIXToolbarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		CGColorRef blackColor = [UIColor colorWithWhite:0.24f alpha:1.0f].CGColor;
		CGColorRef clearColor = [UIColor colorWithWhite:0.24f alpha:0.0f].CGColor;
		layer.colors = [NSArray arrayWithObjects:(id)blackColor, (id)clearColor, nil];
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
