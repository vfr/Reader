//
//	UtilityViewFader.h
//	Reader
//
//	Created by Julius Oklamcak on 2010-09-04.
//	Copyright © 2010-2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import<UIKit/UIKit.h>

@interface UtilityViewFader : NSObject
{
@private // Instance variables

	UIView *_view;
	NSTimer *_timer;

	NSTimeInterval _interval;
	NSTimeInterval _duration;
}

- (id)initWithView:(UIView *)view;
- (id)initWithView:(UIView *)view interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration;

- (void)stopFadeOutTimer;
- (void)startFadeOutTimer;
- (void)startViewFadeIn;

@end
