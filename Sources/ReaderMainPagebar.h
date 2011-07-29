//
//	ReaderMainPagebar.h
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

@class ReaderDocument;
@class ReaderMainPagebar;

@protocol ReaderMainPagebarDelegate <NSObject>

@required // Delegate protocols

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page;

@end

@interface ReaderMainPagebar : UIView
{
@private // Instance variables

	ReaderDocument *document;

	UISlider *thePageSlider;

	UIView *pageNumberView;

	UILabel *pageNumberLabel;

	NSInteger lastPageTrack;
}

@property (nonatomic, assign, readwrite) id <ReaderMainPagebarDelegate> delegate;

- (void)setReaderDocument:(ReaderDocument *)object;

- (void)updatePageNumberDisplay;

- (void)hidePagebar;
- (void)showPagebar;

@end
