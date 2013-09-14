//
//  BRBooksView.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRBooksView.h"
#import "BRBookCell.h"
#import "BRWifiReminderView.h"
#import "BRNotificationView.h"

@interface BRBooksView () <BRBookCellDelegate>
@end

@implementation BRBooksView

+ (PSTCollectionViewFlowLayout *)defaultLayout
{
	PSTCollectionViewFlowLayout *layout = [[PSTCollectionViewFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(70, 90);
	layout.minimumInteritemSpacing = 11;
	layout.minimumLineSpacing = 50;
	return layout;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PSTCollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
		self.showsVerticalScrollIndicator = NO;
		self.backgroundColor = [UIColor clearColor];
		[self registerClass:[BRBookCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
		[self registerClass:[BRNotificationView class] forSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderViewIdentifier];
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
			[_booksViewDelegate booksView:self tappedBookCell:cell];
		}
	}
}

+ (CGFloat)headerHeight
{
	return 120.0f;
}

#pragma mark - BRBookCellDelegate

- (void)deleteBook:(BRBookCell *)bookCell
{
	[_booksViewDelegate booksView:self deleteBookCell:bookCell];
}

@end
