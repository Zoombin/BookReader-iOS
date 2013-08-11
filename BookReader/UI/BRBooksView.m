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
	PSUICollectionViewFlowLayout *_gridLayout = [[PSUICollectionViewFlowLayout alloc] init];
	_gridLayout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_gridLayout.itemSize = CGSizeMake(70, 89);
	_gridLayout.minimumInteritemSpacing = 11;
	_gridLayout.footerReferenceSize = CGSizeMake(frame.size.width, 90);
	_gridLayout.headerReferenceSize = CGSizeMake(frame.size.width, 90);
	_gridLayout.minimumLineSpacing = 20;
	_gridLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 30);
	
    self = [super initWithFrame:frame collectionViewLayout:_gridLayout];
    if (self) {
		self.showsVerticalScrollIndicator = NO;
		self.backgroundColor = [UIColor clearColor];
		[self registerClass:[BRBookCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
		[self registerClass:[BRNotificationView class] forSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderViewIdentifier];
		[self registerClass:[BRWifiReminderView class] forSupplementaryViewOfKind:PSTCollectionElementKindSectionFooter withReuseIdentifier:collectionFooterViewIdentifier];
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

#pragma mark - BRBookCellDelegate
- (void)changedValueBookCell:(BRBookCell *)bookCell
{
	[self.booksViewDelegate booksView:self changedValueBookCell:bookCell];
}

@end
