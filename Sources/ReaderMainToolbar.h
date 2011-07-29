//
//	ReaderMainToolbar.h
//	Reader v2.0.0
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

@class ReaderMainToolbar;

@protocol ReaderMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIBarButtonItem *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIBarButtonItem *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIBarButtonItem *)button;

@end

@interface ReaderMainToolbar : UIToolbar
{
@private // Instance variables

	UILabel *theTitleLabel;
}

@property (nonatomic, assign, readwrite) id <ReaderMainToolbarDelegate> delegate;

- (void)setToolbarTitle:(NSString *)title;

- (void)hideToolbar;
- (void)showToolbar;

@end
