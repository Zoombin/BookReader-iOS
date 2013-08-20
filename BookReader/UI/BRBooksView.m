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

+ (PSUICollectionViewFlowLayout *)defaultLayout
{
	PSUICollectionViewFlowLayout *layout = [[PSUICollectionViewFlowLayout alloc] init];
	layout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	layout.itemSize = CGSizeMake(70, 90);
	layout.minimumInteritemSpacing = 11;
	layout.minimumLineSpacing = 50;
	return layout;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PSTCollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
		//layout.footerReferenceSize = CGSizeMake(frame.size.width, 90);
		//self.collectionViewLayout.foot = layout;
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
