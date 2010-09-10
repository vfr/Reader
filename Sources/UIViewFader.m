//
//	UIViewFader.m
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-04.
//	Copyright © 2010 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "UIViewFader.h"

@implementation UIViewFader

#pragma mark Properties

//@synthesize ...;

#pragma mark UIViewFader Instance methods

- (id)initWithView:(UIView *)view
{
	return [self initWithView:view interval:5.0 duration:0.5];
}

- (id)initWithView:(UIView *)view interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration
{
	if ((self = [super init]))
	{
		if (view != nil) // Check for non-nil view
		{
			_view = [view retain];

			_interval = interval;
			_duration = duration;
		}
		else
			NSAssert(NO, @"view == nil");
	}

	return self;
}

- (void)stopFadeOutTimer
{
	[_timer invalidate]; [_timer release], _timer = nil;
}

- (void)startFadeOutTimer
{
	[self stopFadeOutTimer]; // Stop existing timer first

	_timer =	[NSTimer scheduledTimerWithTimeInterval:_interval
				target:self selector:@selector(doViewFadeOut:)
				userInfo:nil repeats:NO];

	[_timer retain]; // Hold on to it
}

- (void)startViewFadeIn
{
	if (_view.hidden == YES) // Only if hidden
	{
		_view.hidden = NO; // Unhide the view first
		[UIView beginAnimations:@"ViewFadeIn" context:NULL];
		[UIView setAnimationDidStopSelector:@selector(viewFadedIn:finished:context:)];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:_duration];
		_view.alpha = 1.0f;
		[UIView commitAnimations];
	}
}

- (void)viewFadedIn:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	_view.userInteractionEnabled = YES; // Enable UI

	[self startFadeOutTimer];
}

- (void)doViewFadeOut:(NSTimer *)timer
{
	if (_view.hidden == NO) // Only if visible
	{
		_view.userInteractionEnabled = NO; // Disable UI

		[UIView beginAnimations:@"ViewFadeOut" context:NULL];
		[UIView setAnimationDidStopSelector:@selector(viewFadedOut:finished:context:)];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:_duration];
		_view.alpha = 0.0f;
		[UIView commitAnimations];
	}
}

- (void)viewFadedOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self stopFadeOutTimer];

	_view.hidden = YES;
}

- (void)dealloc
{
	[_view release];

	[_timer invalidate];
	[_timer release];

	[super dealloc];
}

@end
