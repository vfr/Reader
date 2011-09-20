//
//	ReaderMainToolbar.h
//	Reader v2.4.0
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

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"

@class ReaderMainToolbar;

@protocol ReaderMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button;

@end

@interface ReaderMainToolbar : UIXToolbarView
{
@private // Instance variables

	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
}

@property (nonatomic, assign, readwrite) id <ReaderMainToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

- (void)setBookmarkState:(BOOL)state;

- (void)hideToolbar;
- (void)showToolbar;

@end
