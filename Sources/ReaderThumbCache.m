//
//	ReaderThumbCache.m
//	Reader v2.2.0
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

#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "ReaderThumbFetch.h"
#import "ReaderThumbView.h"

@implementation ReaderThumbCache

#pragma mark Constants

#define CACHE_SIZE 2097152

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderThumbCache class methods

+ (id)sharedInstance
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	static id object = nil;

	static dispatch_once_t predicate = 0;

	dispatch_once(&predicate, ^{ object = [self new]; });

	return object; // ReaderThumbCache singleton
}

+ (NSString *)appCachesPath
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	static NSString *theCachesPath = nil;

	if (theCachesPath == nil) // Create the application caches path the first time we need it
	{
		NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

		theCachesPath = [[cachesPaths objectAtIndex:0] copy]; // Keep a copy for later abusage
	}

	return theCachesPath;
}

+ (NSString *)thumbCachePathForGUID:(NSString *)guid
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSString *theCachesPath = [ReaderThumbCache appCachesPath]; // App caches path

	return [theCachesPath stringByAppendingPathComponent:guid]; // Append GUID
}

+ (void)createThumbCacheWithGUID:(NSString *)guid
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSString *cachePath = [ReaderThumbCache thumbCachePathForGUID:guid]; // Thumb cache path

	[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];

	[fileManager release]; // Cleanup file manager instance
}

+ (void)removeThumbCacheWithGUID:(NSString *)guid
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
	^{
		NSFileManager *fileManager = [NSFileManager new]; // File manager instance

		NSString *cachePath = [ReaderThumbCache thumbCachePathForGUID:guid]; // Thumb cache path

		[fileManager removeItemAtPath:cachePath error:NULL]; // Remove thumb cache directory

		[fileManager release]; // Cleanup file manager instance
	});
}

#pragma mark ReaderThumbCache instance methods

- (id)init
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init])) // Initialize
	{
		thumbCache = [NSCache new];

		[thumbCache setName:@"ReaderThumbCache"];

		[thumbCache setTotalCostLimit:CACHE_SIZE];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[thumbCache release], thumbCache = nil;

	[super dealloc];
}

- (id)thumbRequest:(ReaderThumbRequest *)request priority:(BOOL)priority
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id object = [thumbCache objectForKey:request.cacheKey];

	if (object == nil) // Thumb object does not yet exist in the cache
	{
		object = [NSNull null]; // Return an NSNull thumb placeholder object

		[thumbCache setObject:object forKey:request.cacheKey cost:2]; // Cache the placeholder object

		ReaderThumbFetch *thumbFetch = [[ReaderThumbFetch alloc] initWithRequest:request]; // Create a thumb fetch operation

		[thumbFetch setQueuePriority:(priority ? NSOperationQueuePriorityNormal : NSOperationQueuePriorityLow)]; // Queue priority

		request.thumbView.operation = thumbFetch; [thumbFetch setThreadPriority:(priority ? 0.55 : 0.35)]; // Thread priority

		[[ReaderThumbQueue sharedInstance] addLoadOperation:thumbFetch]; [thumbFetch release]; // Queue the operation
	}

	return object; // NSNull or UIImage
}

- (void)setObject:(UIImage *)image forKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSUInteger bytes = (image.size.width * image.size.height * 4.0f);

	[thumbCache setObject:image forKey:key cost:bytes]; // Cache image
}

- (void)removeObjectForKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[thumbCache removeObjectForKey:key];
}

- (void)removeNullForKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id object = [thumbCache objectForKey:key];

	if ([object isMemberOfClass:[NSNull class]])
	{
		[thumbCache removeObjectForKey:key];
	}
}

- (void)removeAllObjects
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[thumbCache removeAllObjects];
}

@end
