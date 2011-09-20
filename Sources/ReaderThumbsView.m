//
//	ReaderThumbsView.m
//	Reader v2.4.0
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

#import "ReaderThumbsView.h"

@implementation ReaderThumbsView

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderThumbsView instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.autoresizesSubviews = NO;
		self.alwaysBounceVertical = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];

		[super setDelegate:self]; // Set the UIScrollView superclass delegate

		thumbCellsQueue = [NSMutableArray new]; thumbCellsVisible = [NSMutableArray new]; // Cell management arrays

		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		//tapGesture.numberOfTouchesRequired = 1; tapGesture.numberOfTapsRequired = 1; tapGesture.delegate = self;
		[self addGestureRecognizer:tapGesture]; [tapGesture release];

		lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[thumbCellsQueue release], thumbCellsQueue = nil;

	[thumbCellsVisible release], thumbCellsVisible = nil;

	[super dealloc];
}

- (void)requeueThumbCell:(ReaderThumbView *)tvCell
{
#ifdef DEBUGX
	NSLog(@"%s %d", __FUNCTION__, tvCell.tag);
#endif

	[thumbCellsQueue addObject:tvCell];

	[thumbCellsVisible removeObject:tvCell];

	tvCell.tag = NSIntegerMin; tvCell.hidden = YES;

	[tvCell reuse]; // Reuse the cell
}

- (void)requeueAllThumbCells
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (thumbCellsVisible.count > 0)
	{
		NSArray *visible = [thumbCellsVisible copy];

		for (ReaderThumbView *tvCell in visible)
		{
			[self requeueThumbCell:tvCell];
		}

		[visible release]; // Cleanup
	}
}

- (ReaderThumbView *)dequeueThumbCellWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));
#endif

	ReaderThumbView *theCell = nil;

	if (thumbCellsQueue.count > 0) // Reuse existing cell
	{
		theCell = [[thumbCellsQueue objectAtIndex:0] retain];

		[thumbCellsQueue removeObjectAtIndex:0]; // Dequeue it

		theCell.frame = frame; // Position the reused cell
	}
	else // Allocate a brand new thumb cell subclass for our use
	{
		theCell = [[delegate thumbsView:self thumbCellWithFrame:frame] retain];

		assert([theCell isKindOfClass:[ReaderThumbView class]]); // Check

		theCell.tag = NSIntegerMin; theCell.hidden = YES;

		[self insertSubview:theCell atIndex:0]; // Add
	}

	[thumbCellsVisible addObject:theCell]; [theCell release];

	return theCell;
}

- (NSMutableIndexSet *)visibleIndexSetForContentOffset
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));
#endif

	CGFloat minY = self.contentOffset.y; // Content offset
	CGFloat maxY = (minY + self.bounds.size.height - 1.0f);

	NSInteger startRow = (minY / _thumbSize.height); // Start row
	NSInteger finalRow = (maxY / _thumbSize.height); // Final row

	NSInteger startIndex = (startRow * _thumbsX); // Start index
	NSInteger finalIndex = (finalRow * _thumbsX); // Final index

	finalIndex += (_thumbsX - 1); // Last index value in last row

	NSInteger maximumIndex = (_thumbCount - 1); // Maximum index value

	if (finalIndex > maximumIndex) finalIndex = maximumIndex; // Limit it

	NSRange indexRange = NSMakeRange(startIndex, (finalIndex - startIndex + 1));

	return [NSMutableIndexSet indexSetWithIndexesInRange:indexRange];
}

- (ReaderThumbView *)thumbCellContainingPoint:(CGPoint)point
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(point));
#endif

	ReaderThumbView *theCell = nil;

	for (ReaderThumbView *tvCell in thumbCellsVisible)
	{
		if (CGRectContainsPoint(tvCell.frame, point) == true)
		{
			theCell = tvCell; break; // Found it
		}
	}

	return theCell;
}

- (CGRect)thumbCellFrameForIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s %d", __FUNCTION__, index);
#endif

	CGRect thumbRect; thumbRect.size = _thumbSize;

	NSInteger thumbY = ((index / _thumbsX) * _thumbSize.height); // X, Y

	NSInteger thumbX = (((index % _thumbsX) * _thumbSize.width) + _thumbX);

	thumbRect.origin.x = thumbX; thumbRect.origin.y = thumbY;

	return thumbRect;
}

- (void)updateContentSize:(NSUInteger)thumbCount
{
#ifdef DEBUGX
	NSLog(@"%s %d", __FUNCTION__, thumbCount);
#endif

	canUpdate = NO; // Disable updates

	if (thumbCount > 0) // Have some thumbs
	{
		CGFloat bw = self.bounds.size.width;
		CGFloat bh = self.bounds.size.height;

		_thumbsX = (bw / _thumbSize.width);

		if (_thumbsX < 1) _thumbsX = 1;

		_thumbsY = (thumbCount / _thumbsX);

		if ((_thumbsX * _thumbsY) < thumbCount) _thumbsY++;

		CGFloat tw = (_thumbsX * _thumbSize.width);
		CGFloat th = (_thumbsY * _thumbSize.height);

		if (tw < bw)
			_thumbX = ((bw - tw) / 2.0f);
		else
			_thumbX = 0; // Reset

		if (tw < bw) tw = bw; if (th < bh) th = bh;

		[self setContentSize:CGSizeMake(tw, th)];
	}
	else // Zero (0) thumbs
	{
		[self setContentSize:CGSizeZero];
	}

	canUpdate = YES; // Enable updates
}

- (void)layoutSubviews
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));
#endif

	if (CGSizeEqualToSize(_viewSize, CGSizeZero) == true)
	{
		_viewSize = self.bounds.size; // Initial view size
	}
	else
	if (CGSizeEqualToSize(_viewSize, self.bounds.size) == false)
	{
		_viewSize = self.bounds.size; // Track the view size

		[self updateContentSize:_thumbCount]; // Update the content size

		NSMutableArray *requeueCells = [NSMutableArray array]; // Requeue cell list

		NSMutableIndexSet *visibleIndexSet = [self visibleIndexSetForContentOffset];

		for (ReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
		{
			NSInteger index = tvCell.tag; // Get the cell's index value

			if ([visibleIndexSet containsIndex:index] == YES) // Visible cell
			{
				tvCell.frame = [self thumbCellFrameForIndex:index]; // Frame

				[visibleIndexSet removeIndex:index]; // Remove from set
			}
			else // Add it to the list of cells to requeue
			{
				[requeueCells addObject:tvCell];
			}
		}

		for (ReaderThumbView *tvCell in requeueCells) // Enumerate requeue cells
		{
			[self requeueThumbCell:tvCell]; // Requeue the thumb cell
		}

		[visibleIndexSet enumerateIndexesUsingBlock: // Enumerate visible indexes
			^(NSUInteger index, BOOL *stop)
			{
				CGRect thumbRect = [self thumbCellFrameForIndex:index]; // Frame

				ReaderThumbView *tvCell = [self dequeueThumbCellWithFrame:thumbRect];

				[delegate thumbsView:self updateThumbCell:tvCell forIndex:index];

				tvCell.tag = index; tvCell.hidden = NO; // Tag and show it
			}
		];
	}
}

- (void)setThumbSize:(CGSize)thumbSize
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGSize(thumbSize));
#endif

	if (CGSizeEqualToSize(_thumbSize, CGSizeZero) == true)
	{
		if (CGSizeEqualToSize(thumbSize, CGSizeZero) == false)
		{
			_thumbSize = thumbSize; // Set the maximum thumb size
		}
	}
}

- (void)reloadThumbsCenterOnIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(delegate != nil); // Check delegate

	assert(CGSizeEqualToSize(_thumbSize, CGSizeZero) == false);

	if (self.decelerating == YES) // Stop scroll view movement
	{
		[self setContentOffset:self.contentOffset animated:NO];
	}

	CGPoint newContentOffset = CGPointZero; // At top

	lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);

	[self requeueAllThumbCells]; // Start off fresh

	_thumbCount = 0; // Reset the thumb count to zero

	NSUInteger thumbCount = [delegate numberOfThumbsInThumbsView:self];

	[self updateContentSize:thumbCount]; _thumbCount = thumbCount;

	if (thumbCount > 0) // Have some thumbs
	{
		NSInteger boundsHeight = self.bounds.size.height;

		NSInteger maxY = (self.contentSize.height - boundsHeight);

		NSInteger minY = 0; maxY--; if (maxY < minY) maxY = minY; // Limits

		if (index < 0) index = 0; else if (index > thumbCount) index = (thumbCount - 1);

		NSInteger thumbY = ((index / _thumbsX) * _thumbSize.height); // Thumb Y

		NSInteger offsetY = (thumbY - (boundsHeight / 2) + (_thumbSize.height / 2));

		if (offsetY < minY) offsetY = minY; else if (offsetY > maxY) offsetY = maxY;

		newContentOffset.y = offsetY; // Calculated content offset Y position
	}

	if (CGPointEqualToPoint(self.contentOffset, newContentOffset) == false)
		[self setContentOffset:newContentOffset animated:NO];
	else
		[self scrollViewDidScroll:self];

	[self flashScrollIndicators];
}

- (void)reloadThumbsContentOffset:(CGPoint)newContentOffset
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(delegate != nil); // Check delegate

	assert(CGSizeEqualToSize(_thumbSize, CGSizeZero) == false);

	if (self.decelerating == YES) // Stop scroll view movement
	{
		[self setContentOffset:self.contentOffset animated:NO];
	}

	lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);

	[self requeueAllThumbCells]; // Start off fresh

	_thumbCount = 0; // Reset the thumb count to zero

	NSUInteger thumbCount = [delegate numberOfThumbsInThumbsView:self];

	[self updateContentSize:thumbCount]; _thumbCount = thumbCount;

	if (thumbCount > 0) // Have some thumbs
	{
		NSInteger boundsHeight = self.bounds.size.height;

		NSInteger maxY = (self.contentSize.height - boundsHeight);

		NSInteger minY = 0; maxY--; if (maxY < minY) maxY = minY; // Limits

		NSInteger offsetY = newContentOffset.y; // Requested content offset Y

		if (offsetY < minY) offsetY = minY; else if (offsetY > maxY) offsetY = maxY;

		newContentOffset.y = offsetY; newContentOffset.x = 0.0f; // Validated
	}
	else // Zero (0) thumbs
	{
		newContentOffset = CGPointZero;
	}

	if (CGPointEqualToPoint(self.contentOffset, newContentOffset) == false)
		[self setContentOffset:newContentOffset animated:NO];
	else
		[self scrollViewDidScroll:self];

	[self flashScrollIndicators];
}

- (void)refreshThumbWithIndex:(NSInteger)index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	for (ReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
	{
		if (tvCell.tag == index) // Found a visible thumb cell with the index value
		{
			if ([delegate respondsToSelector:@selector(thumbsView:refreshThumbCell:forIndex:)])
			{
				[delegate thumbsView:self refreshThumbCell:tvCell forIndex:index]; // Refresh
			}

			break;
		}
	}
}

- (void)refreshVisibleThumbs
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	for (ReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
	{
		if ([delegate respondsToSelector:@selector(thumbsView:refreshThumbCell:forIndex:)])
		{
			[delegate thumbsView:self refreshThumbCell:tvCell forIndex:tvCell.tag]; // Refresh
		}
	}
}

#pragma mark UIGestureRecognizer action methods

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPoint point = [recognizer locationInView:recognizer.view]; // Location

	ReaderThumbView *tvCell = [self thumbCellContainingPoint:point]; // Look for cell

	if (tvCell != nil) [delegate thumbsView:self didSelectThumbWithIndex:tvCell.tag];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint(scrollView.contentOffset));
#endif

	if ((canUpdate == YES) && (_thumbCount > 0)) // Check flag and thumb count
	{
		if (CGPointEqualToPoint(scrollView.contentOffset, lastContentOffset) == false)
		{
			lastContentOffset = scrollView.contentOffset; // Work around a 'feature'

			CGRect visibleBounds = self.bounds; // Visible bounds in the scroll view

			NSMutableArray *requeueCells = [NSMutableArray array]; // Requeue cell list

			NSMutableIndexSet *visibleCellSet = [NSMutableIndexSet indexSet]; // Visible set

			for (ReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
			{
				if (CGRectIntersectsRect(tvCell.frame, visibleBounds) == true)
					[visibleCellSet addIndex:tvCell.tag];
				else
					[requeueCells addObject:tvCell];
			}

			for (ReaderThumbView *tvCell in requeueCells) // Enumerate requeue cells
			{
				[self requeueThumbCell:tvCell]; // Requeue the thumb cell
			}

			NSMutableIndexSet *visibleIndexSet = [self visibleIndexSetForContentOffset];

			[visibleIndexSet enumerateIndexesUsingBlock: // Enumerate visible indexes
				^(NSUInteger index, BOOL *stop)
				{
					if ([visibleCellSet containsIndex:index] == NO) // Index not visible
					{
						CGRect thumbRect = [self thumbCellFrameForIndex:index]; // Frame

						ReaderThumbView *tvCell = [self dequeueThumbCellWithFrame:thumbRect];

						[delegate thumbsView:self updateThumbCell:tvCell forIndex:index];

						tvCell.tag = index; tvCell.hidden = NO; // Tag and show it
					}
				}
			];
		}
	}
}

@end
