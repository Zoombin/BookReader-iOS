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
	_layout = [[PSUICollectionViewFlowLayout alloc] init];
	_layout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_layout.itemSize = CGSizeMake(70, 90);
	_layout.minimumInteritemSpacing = 11;
	//_layout.footerReferenceSize = CGSizeMake(frame.size.width, 90);
	_layout.minimumLineSpacing = 50;
	_layout.sectionInset = kLessBookEdgeInsets;
		
    self = [super initWithFrame:frame collectionViewLayout:_layout];
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
