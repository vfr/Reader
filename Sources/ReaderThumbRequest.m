//
//	ReaderThumbRequest.m
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

#import "ReaderThumbRequest.h"
#import "ReaderThumbView.h"

@implementation ReaderThumbRequest

#pragma mark Properties

@synthesize guid = _guid;
@synthesize fileURL = _fileURL;
@synthesize password = _password;
@synthesize thumbView = _thumbView;
@synthesize thumbPage = _thumbPage;
@synthesize thumbSize = _thumbSize;
@synthesize thumbName = _thumbName;
@synthesize targetTag = _targetTag;
@synthesize cacheKey = _cacheKey;
@synthesize scale = _scale;

#pragma mark ReaderThumbRequest class methods

+ (id)forView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [[[ReaderThumbRequest alloc] initWithView:view fileURL:url password:phrase guid:guid page:page size:size] autorelease];
}

#pragma mark ReaderThumbRequest instance methods

- (id)initWithView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init])) // Initialize object
	{
		NSInteger w = size.width; NSInteger h = size.height;

		_thumbView = [view retain]; _thumbPage = page; _thumbSize = size;

		_fileURL = [url copy]; _password = [phrase copy]; _guid = [guid copy];

		_thumbName = [[NSString alloc] initWithFormat:@"%08X-%07d-%04dx%04d", _fileURL.hash, page, w, h];

		_cacheKey = [[NSString alloc] initWithFormat:@"%@+%@", _thumbName, _guid];

		_targetTag = [_thumbName hash]; _thumbView.targetTag = _targetTag;

		_scale = [[UIScreen mainScreen] scale]; // Thumb screen scale
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[_guid release], _guid = nil;

	[_fileURL release], _fileURL = nil;

	[_password release], _password = nil;

	[_thumbView release], _thumbView = nil;

	[_thumbName release], _thumbName = nil;

	[_cacheKey release], _cacheKey = nil;

	[super dealloc];
}

@end
