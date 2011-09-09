//
//	ReaderThumbQueue.h
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

#import <Foundation/Foundation.h>

@interface ReaderThumbQueue : NSObject
{
@private // Instance variables

	NSOperationQueue *loadQueue;

	NSOperationQueue *workQueue;
}

+ (id)sharedInstance;

- (void)addLoadOperation:(NSOperation *)operation;

- (void)addWorkOperation:(NSOperation *)operation;

- (void)cancelOperationsWithGUID:(NSString *)guid;

- (void)cancelAllOperations;

@end

#pragma mark -

//
//	ReaderThumbOperation class interface
//

@interface ReaderThumbOperation : NSOperation
{
@protected // Instance variables

	NSString *_guid;
}

@property (nonatomic, retain, readonly) NSString *guid;

- (id)initWithGUID:(NSString *)guid;

@end
