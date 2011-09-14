//
//	ReaderThumbRequest.h
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

@class ReaderThumbView;

@interface ReaderThumbRequest : NSObject
{
@private // Instance variables

	NSURL *_fileURL;

	NSString *_guid;

	NSString *_password;

	NSString *_cacheKey;

	NSString *_thumbName;

	ReaderThumbView *_thumbView;

	NSUInteger _targetTag;

	NSInteger _thumbPage;

	CGSize _thumbSize;

	CGFloat _scale;
}

@property (nonatomic, retain, readonly) NSURL *fileURL;
@property (nonatomic, retain, readonly) NSString *guid;
@property (nonatomic, retain, readonly) NSString *password;
@property (nonatomic, retain, readonly) NSString *cacheKey;
@property (nonatomic, retain, readonly) NSString *thumbName;
@property (nonatomic, retain, readonly) ReaderThumbView *thumbView;
@property (nonatomic, assign, readonly) NSUInteger targetTag;
@property (nonatomic, assign, readonly) NSInteger thumbPage;
@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, assign, readonly) CGFloat scale;

+ (id)forView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size;

- (id)initWithView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size;

@end
