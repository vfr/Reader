//
//	ReaderThumbsView.h
//	Reader v2.3.0
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

#import <UIKit/UIKit.h>

#import "ReaderThumbView.h"

@class ReaderThumbsView;

@protocol ReaderThumbsViewDelegate <NSObject, UIScrollViewDelegate>

@required // Delegate protocols

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView;

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame;

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(id)thumbCell forIndex:(NSInteger)index;

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index;

@optional // Delegate protocols

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(id)thumbCell forIndex:(NSInteger)index;

@end

@interface ReaderThumbsView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
@private // Instance variables

	CGPoint lastContentOffset;

	NSMutableArray *thumbCellsQueue;

	NSMutableArray *thumbCellsVisible;

	NSInteger _thumbsX, _thumbsY, _thumbX;

	CGSize _thumbSize, _viewSize;

	NSUInteger _thumbCount;

	BOOL canUpdate;
}

@property (nonatomic, assign, readwrite) id <ReaderThumbsViewDelegate> delegate;

- (void)setThumbSize:(CGSize)thumbSize;

- (void)reloadThumbsCenterOnIndex:(NSInteger)index;

- (void)reloadThumbsContentOffset:(CGPoint)newContentOffset;

- (void)refreshThumbWithIndex:(NSInteger)index;

- (void)refreshVisibleThumbs;

@end
