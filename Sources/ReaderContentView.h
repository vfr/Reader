//
//	ReaderContentView.h
//	Reader v2.2.0
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

#import "ReaderThumbView.h"

@class ReaderScrollView;
@class ReaderContentPage;
@class ReaderContentThumb;

@protocol ReaderContentViewDelegate <NSObject>

@required // Delegate protocols

- (void)scrollViewTouchesBegan:(UIScrollView *)scrollView touches:(NSSet *)touches;

@end

@interface ReaderContentView : UIView <UIScrollViewDelegate>
{
@private // Instance variables

	ReaderScrollView *theScrollView;

	ReaderContentPage *theContentView;

	ReaderContentThumb *theThumbView;

	UIView *theContainerView;
}

@property (nonatomic, assign, readwrite) id <ReaderContentViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page password:(NSString *)phrase;

- (void)showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase guid:(NSString *)guid;

- (id)singleTap:(UITapGestureRecognizer *)recognizer;

- (void)zoomIncrement;
- (void)zoomDecrement;
- (void)zoomReset;

@end

#pragma mark -

//
//	ReaderContentThumb class interface
//

@interface ReaderContentThumb : ReaderThumbView
{
@private // Instance variables
}

@end
