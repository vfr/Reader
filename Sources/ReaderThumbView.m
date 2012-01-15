//
//	ReaderThumbView.m
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-09-01.
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

#import "ReaderThumbView.h"

@implementation ReaderThumbView

#pragma mark Properties

@synthesize operation = _operation;
@synthesize targetTag = _targetTag;

#pragma mark ReaderThumbView instance methods

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
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor clearColor];

		imageView = [[UIImageView alloc] initWithFrame:self.bounds];

		imageView.autoresizesSubviews = NO;
		imageView.userInteractionEnabled = NO;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.autoresizingMask = UIViewAutoresizingNone;
		imageView.backgroundColor = [UIColor clearColor];

		[self addSubview:imageView];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[imageView release], imageView = nil;

	[super dealloc];
}

- (void)showImage:(UIImage *)image
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	imageView.image = image; // Show image
}

- (void)showTouched:(BOOL)touched
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
}

- (void)removeFromSuperview
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	_targetTag = 0; // Clear target tag

	[self.operation cancel], self.operation = nil;

	[super removeFromSuperview];
}

- (void)reuse
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	_targetTag = 0; // Clear target tag

	[self.operation cancel], self.operation = nil;

	imageView.image = nil; // Release image
}

@end
