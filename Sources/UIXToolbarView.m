//
//	UIXToolbarView.m
//	Reader v2.6.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
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

#import "UIXToolbarView.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIXToolbarView

#pragma mark Constants

#define SHADOW_HEIGHT 4.0f

#pragma mark UIXToolbarView class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark UIXToolbarView instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		UIColor *liteColor = [UIColor colorWithWhite:0.92f alpha:0.8f];
		UIColor *darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f];
		layer.colors = [NSArray arrayWithObjects:(id)liteColor.CGColor, (id)darkColor.CGColor, nil];

		CGRect shadowRect = self.bounds; shadowRect.origin.y += shadowRect.size.height; shadowRect.size.height = SHADOW_HEIGHT;

		UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];

		[self addSubview:shadowView]; 
	}

	return self;
}

@end

#pragma mark -

//
//	UIXToolbarShadow class implementation
//

@implementation UIXToolbarShadow

#pragma mark UIXToolbarShadow class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark UIXToolbarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		UIColor *blackColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		UIColor *clearColor = [UIColor colorWithWhite:0.24f alpha:0.0f];
		layer.colors = [NSArray arrayWithObjects:(id)blackColor.CGColor, (id)clearColor.CGColor, nil];
	}

	return self;
}

@end
