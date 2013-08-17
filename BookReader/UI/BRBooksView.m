//
//  BRBooksView.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRBooksView.h"
#import "BRBookCell.h"
#import "Book.h"
#import "BRWifiReminderView.h"
#import "BRNotificationView.h"

@interface BRBooksView () <BRBookCellDelegate>
@end

@implementation BRBooksView


- (id)initWithFrame:(CGRect)frame
{
	_gridLayout = [[PSUICollectionViewFlowLayout alloc] init];
	_gridLayout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_gridLayout.itemSize = CGSizeMake(70, 90);
	_gridLayout.minimumInteritemSpacing = 11;
	_gridLayout.headerReferenceSize = CGSizeMake(frame.size.width, [[self class] headerHeight]);
	//_gridLayout.footerReferenceSize = CGSizeMake(frame.size.width, 90);
	_gridLayout.minimumLineSpacing = 50;
	_gridLayout.sectionInset = kLessBookEdgeInsets;
	
	_layoutWithoutHeader = [[PSUICollectionViewFlowLayout alloc] init];
	_layoutWithoutHeader.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_layoutWithoutHeader.itemSize = CGSizeMake(70, 90);
	_layoutWithoutHeader.minimumInteritemSpacing = 11;
	_layoutWithoutHeader.headerReferenceSize = CGSizeMake(frame.size.width, 0);
	_layoutWithoutHeader.minimumLineSpacing = 50;
	_layoutWithoutHeader.sectionInset = kLessBookEdgeInsets;
	
    self = [super initWithFrame:frame collectionViewLayout:_gridLayout];
    if (self) {
		self.showsVerticalScrollIndicator = NO;
		self.backgroundColor = [UIColor clearColor];
		[self registerClass:[BRBookCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
		[self registerClass:[BRNotificationView class] forSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderViewIdentifier];
		//[self registerClass:[BRWifiReminderView class] forSupplementaryViewOfKind:PSTCollectionElementKindSectionFooter withReuseIdentifier:collectionFooterViewIdentifier];
		self.allowsSelection = NO;
		UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self addGestureRecognizer:tapRecognizer];
	}
	return self;
}

- (BRBookCell *)bookCell:(Book *)book atIndexPath:(NSIndexPath *)indexPath
{
	BRBookCell *cell = [self dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
	cell.bookCellDelegate = self;
	[cell setBook:book];
	return cell;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		CGPoint initialPinchPoint = [gesture locationInView:self];
		NSIndexPath *indexPath = [self indexPathForItemAtPoint:initialPinchPoint];
		if (indexPath) {
			BRBookCell *cell = (BRBookCell *)[self cellForItemAtIndexPath:indexPath];
			[self.booksViewDelegate booksView:self tappedBookCell:cell];
		}
	}
}

+ (CGFloat)headerHeight
{
	return 120.0f;
}

#pragma mark - BRBookCellDelegate
- (void)changedValueBookCell:(BRBookCell *)bookCell
{
	[self.booksViewDelegate booksView:self changedValueBookCell:bookCell];
}

@end
